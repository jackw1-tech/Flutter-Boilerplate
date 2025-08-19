import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() => runApp(MaterialApp(home: BLEPrinterExplorer()));

class BLEPrinterExplorer extends StatefulWidget {
  @override
  _BLEPrinterExplorerState createState() => _BLEPrinterExplorerState();
}

class _BLEPrinterExplorerState extends State<BLEPrinterExplorer> {
  List<ScanResult> devices = [];
  List<String> previousIds = [];
  BluetoothDevice? selectedDevice;
  List<BluetoothService> services = [];

  void startScan() async {
    final oldIds = Set<String>.from(previousIds);

    // Prepara i dati per la nuova scansione
    setState(() {
      services.clear();
      devices.clear();
    });

    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      print("❌ Bluetooth non attivo: stato = $state");
      return;
    }

    print("🔍 Avvio scansione BLE...");
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      final newIds = results.map((r) => r.device.id.toString()).toSet();

      final added = newIds.difference(oldIds);
      final removed = oldIds.difference(newIds);

      for (var id in added) {
        print("🟢 Nuovo dispositivo rilevato: $id");
      }
      for (var id in removed) {
        print("🔴 Dispositivo scomparso: $id");
      }

      setState(() {
        devices = results;
        previousIds = newIds.toList();
      });
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();
    try {
      await device.connect(timeout: Duration(seconds: 10));
    } catch (_) {}
    final connState = await device.connectionState.firstWhere(
        (s) => s == BluetoothConnectionState.connected,
        orElse: () => BluetoothConnectionState.disconnected);
    if (connState != BluetoothConnectionState.connected) {
      print("❌ Connessione fallita a ${device.id}");
      return;
    }
    selectedDevice = device;
    print("✅ Connesso a ${device.id}");

    try {
      services = await device.discoverServices();
    } catch (e) {
      print("❌ Errore discoverServices: $e");
      return;
    }

    for (var s in services) {
      print("➡️ Servizio: ${s.uuid}");
      for (var c in s.characteristics) {
        print("   🧬 ${c.uuid} write:${c.properties.write}");
      }
    }

    setState(() {});
  }

  void sendTestPrint() async {
    if (services.isEmpty) {
      print("❌ Nessun servizio disponibile");
      return;
    }

    final bytes = [
      0x1B,
      0x40,
      ...'Ciao :-) \n'.codeUnits,
      0x1D,
      0x56,
      0x41,
      0x10,
    ];

    bool sent = false;
    print("📤 Inizio invio comando di stampa...");

    for (var s in services) {
      for (var c in s.characteristics) {
        if (c.properties.write || c.properties.writeWithoutResponse) {
          print("✍️ Scrittura su: ${c.uuid}");
          try {
            await c.write(bytes, withoutResponse: false);
            print("✅ Comando inviato a: ${c.uuid}");
            sent = true;
            break;
          } catch (e) {
            print("❌ Errore scrittura: $e");
          }
        }
      }
      if (sent) break;
    }

    if (!sent) print("⚠️ Nessuna caratteristica scrivibile trovata.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BLE Printer Explorer")),
      body: Column(
        children: [
          ElevatedButton(onPressed: startScan, child: Text("Scansiona BLE")),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(devices.isEmpty
                ? "Nessun dispositivo trovato."
                : "Dispositivi trovati: ${devices.length}"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (ctx, i) {
                final d = devices[i].device;

                return FutureBuilder<BluetoothConnectionState>(
                  future: d.connectionState.first,
                  builder: (context, snapshot) {
                    final isConnected =
                        snapshot.data == BluetoothConnectionState.connected;

                    return ListTile(
                      leading: Icon(
                        isConnected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        color: isConnected ? Colors.green : Colors.grey,
                      ),
                      title: Text(d.name.isNotEmpty ? d.name : "(senza nome)"),
                      subtitle: Text(d.id.toString()),
                      onTap: () => connectToDevice(d),
                    );
                  },
                );
              },
            ),
          ),
          if (services.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: sendTestPrint,
                child: Text("Invia testo"),
              ),
            ),
        ],
      ),
    );
  }
}
