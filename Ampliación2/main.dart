import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Datos Alpha Vantage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StockPage(),
    );
  }
}

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  Future<Map<String, dynamic>>? futureStockData;
  String selectedSymbol = 'IBM'; // Símbolo predeterminado

  final List<String> symbols = [
    'IBM',
    'AAPL',
    'GOOGL',
    'MSFT',
  ];

  // Controlador para el cuadro de texto
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData(); // Obtener datos iniciales
    _controller.text = selectedSymbol; // Muestra el símbolo predeterminado en el TextField
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Actualiza la consulta a la API con el símbolo seleccionado o ingresado
  void _fetchData() {
    futureStockData = fetchStockData(selectedSymbol);
  }

  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    final apiKey = 'TU API KEY AQUÍ'; // Reemplaza con tu API key de Alpha Vantage
    final url = Uri.parse(
        'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('Global Quote')) {
        return jsonResponse['Global Quote'];
      } else {
        throw Exception('No se encontraron datos para el símbolo $symbol');
      }
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cotización Alpha Vantage'),
      ),
      body: Column(
        children: [
          // Dropdown para seleccionar un símbolo (opcional)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedSymbol,
              items: symbols.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedSymbol = newValue!;
                  _controller.text = selectedSymbol;
                  _fetchData();
                });
              },
            ),
          ),
          // Muestra la información de la cotización actual
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: futureStockData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  final symbol = data['01. symbol'] ?? 'N/A';
                  final open = data['02. open'] ?? 'N/A';
                  final high = data['03. high'] ?? 'N/A';
                  final low = data['04. low'] ?? 'N/A';
                  final price = data['05. price'] ?? 'N/A';
                  final volume = data['06. volume'] ?? 'N/A';
                  final latestTradingDay = data['07. latest trading day'] ?? 'N/A';
                  final previousClose = data['08. previous close'] ?? 'N/A';
                  final change = data['09. change'] ?? 'N/A';
                  final changePercent = data['10. change percent'] ?? 'N/A';

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Símbolo: $symbol',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Precio actual: \$ $price',
                            style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Apertura: \$ $open'),
                        Text('Máximo: \$ $high'),
                        Text('Mínimo: \$ $low'),
                        SizedBox(height: 8),
                        Text('Volumen: $volume'),
                        SizedBox(height: 8),
                        Text('Último día de negociación: $latestTradingDay'),
                        SizedBox(height: 8),
                        Text('Cierre previo: \$ $previousClose'),
                        SizedBox(height: 8),
                        Text('Cambio: \$ $change'),
                        Text('Cambio porcentual: $changePercent'),
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text('No hay datos disponibles'));
                }
              },
            ),
          ),
          // Cuadro de texto y ElevatedButton para ingresar un símbolo manualmente
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Campo de texto para el símbolo
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Ingresa símbolo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Botón para actualizar los datos
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedSymbol = _controller.text.toUpperCase().trim();
                      _fetchData();
                    });
                  },
                  child: Text('Actualizar'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
