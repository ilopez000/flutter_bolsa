import 'package:flutter/material.dart'; // Importa el paquete de Material Design de Flutter para widgets y estilos
import 'dart:convert'; // Importa dart:convert para codificar y decodificar datos JSON
import 'package:http/http.dart' as http; // Importa el paquete http para realizar solicitudes HTTP

void main() {
  // Función principal, el punto de entrada de la aplicación
  runApp(MyApp()); // Inicia la aplicación Flutter con el widget MyApp
}

class MyApp extends StatelessWidget {
  // MyApp es un widget StatelessWidget, no mantiene estado mutable
  @override
  Widget build(BuildContext context) {
    // Método build, construye la interfaz de usuario de este widget
    return MaterialApp(
      // MaterialApp configura la aplicación con un tema y la página principal
      title: 'Proyecto Bolsa', // Título de la aplicación
      theme: ThemeData(
        // Tema de la aplicación
        primarySwatch: Colors.blue, // Color principal del tema
      ),
      home: StockPage(), // Widget principal que se muestra al iniciar la app
    );
  }
}

class StockPage extends StatefulWidget {
  // StockPage es un widget StatefulWidget, puede mantener y actualizar su estado
  @override
  _StockPageState createState() => _StockPageState(); // Crea una instancia de _StockPageState
}

class _StockPageState extends State<StockPage> {
  // _StockPageState maneja el estado de StockPage
  Future<Map<String, dynamic>>? futureStockData; // Variable Future para almacenar datos de la API

  @override
  void initState() {
    // Se llama una vez cuando el widget se inserta en el árbol de widgets
    super.initState();
    futureStockData = fetchStockData('IBM'); // Obtiene datos de IBM y los asigna a futureStockData
  }

  // Función para obtener datos de la API de Alpha Vantage
  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    final apiKey = 'B8KCIMNB3OC25QUX'; // Clave API de Alpha Vantage, ¡REEMPLAZAR CON LA PROPIA!
    final url = Uri.parse(
        'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey'); // Construye la URL de la API
    final response = await http.get(url); // Realiza una solicitud GET a la API

    if (response.statusCode == 200) {
      // Verifica si la respuesta fue exitosa (código 200)
      final Map<String, dynamic> jsonResponse = json.decode(response.body); // Decodifica la respuesta JSON
      if (jsonResponse.containsKey('Global Quote')) {
        // Verifica si la respuesta contiene los datos de la acción
        return jsonResponse['Global Quote']; // Retorna los datos de la acción
      } else {
        throw Exception('No se encontraron datos para el símbolo $symbol'); // Lanza excepción si no hay datos
      }
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}'); // Lanza excepción si hay un error en la solicitud
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construye la interfaz de usuario de _StockPageState
    return Scaffold(
      // Scaffold proporciona la estructura básica de la página
      appBar: AppBar(
        // Barra de aplicaciones
        title: Text('Cotización Alpha Vantage'), // Título de la barra de aplicaciones
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        // FutureBuilder construye la interfaz en función del estado del Future
        future: futureStockData, // El Future que se está esperando
        builder: (context, snapshot) {
          // builder se llama con el contexto y un snapshot del Future
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras se espera la respuesta
            return Center(child: CircularProgressIndicator()); // Muestra un indicador de carga
          } else if (snapshot.hasError) {
            // Si ocurre un error
            return Center(child: Text('Error: ${snapshot.error}')); // Muestra un mensaje de error
          } else if (snapshot.hasData) {
            // Si se reciben datos
            final data = snapshot.data!; // Obtiene los datos del snapshot
            // Extrae los datos de cotización
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
              // Agrega relleno alrededor del contenido
              padding: const EdgeInsets.all(16.0),
              child: Column(
                // Muestra los datos en una columna
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
                children: [
                  Text('Símbolo: $symbol', // Muestra el símbolo de la acción
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8), // Espacio vertical
                  Text('Precio actual: \$ $price', // Muestra el precio actual
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8), // Espacio vertical
                  Text('Apertura: \$ $open'), // Muestra el precio de apertura
                  Text('Máximo: \$ $high'), // Muestra el precio máximo
                  Text('Mínimo: \$ $low'), // Muestra el precio mínimo
                  SizedBox(height: 8), // Espacio vertical
                  Text('Volumen: $volume'), // Muestra el volumen
                  SizedBox(height: 8), // Espacio vertical
                  Text('Último día de negociación: $latestTradingDay'), // Muestra el último día de negociación
                  SizedBox(height: 8), // Espacio vertical
                  Text('Cierre previo: \$ $previousClose'), // Muestra el cierre previo
                  SizedBox(height: 8), // Espacio vertical
                  Text('Cambio: \$ $change'), // Muestra el cambio
                  Text('Cambio porcentual: $changePercent'), // Muestra el cambio porcentual
                ],
              ),
            );
          } else {
            return Center(child: Text('No hay datos disponibles')); // Mensaje si no hay datos
          }
        },
      ),
    );
  }
}
