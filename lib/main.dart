import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Erstelle das ProductRepository-Objekt
    ProductRepository productRepository = ProductRepository();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: const Row(
            children: [
              Text('ListView Exercise'),
            ],
          ),
        ),
        body: Center(
          // Übergebe das ProductRepository an MyWidget
          child: MyWidget(productRepository: productRepository),
        ),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  final ProductRepository productRepository;

  const MyWidget({Key? key, required this.productRepository}) : super(key: key);

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<Product> products = [];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        // Nutze die Produkte aus dem ProductRepository
        future: widget.productRepository.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Setze die Produkte im State, wenn die Daten geladen sind
            products = snapshot.data as List<Product>;
            return ListView(
              shrinkWrap: false,
              children: products.map(
                (product) {
                  return ProductTile(
                    product: product,
                    inCart: widget.productRepository.isProductInCart(product),
                    onCartChanged: (inCart) {
                      setState(() {
                        if (inCart) {
                          widget.productRepository.addToCart(product);
                        } else {
                          widget.productRepository.removeFromCart(product);
                        }
                      });
                    },
                  );
                },
              ).toList(),
            );
          }
        },
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  final Product product;
  final bool inCart;
  final ValueChanged<bool> onCartChanged;

  const ProductTile({
    Key? key,
    required this.product,
    required this.inCart,
    required this.onCartChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.shopping_cart),
      title: Text(product.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("\$ ${product.price}"),
          IconButton(
            icon: Icon(
              inCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
              color: inCart ? Colors.red : null,
            ),
            onPressed: () {
              onCartChanged(!inCart);
            },
          ),
        ],
      ),
    );
  }
}

class Product {
  String name;
  int price;

  Product(this.name, this.price);
}

class ProductRepository {
  // Statische Liste von Produkten
  static List<Product> products = [
    Product("Äpfel", 2),
    Product("Mango", 3),
    Product("Bananen", 3),
    Product("Orange", 1),
    Product("Strawberry", 2),
  ];

  // Liste für den Warenkorb
  List<Product> cart = [];

  // Methode, um Produkte abzurufen
  Future<List<Product>> getProducts() async {
    // Simuliere eine API-Abruf oder Datenbankabfrage
    await Future.delayed(const Duration(seconds: 2));
    return products;
  }

  // Überprüfe, ob ein Produkt im Warenkorb ist
  bool isProductInCart(Product product) {
    return cart.contains(product);
  }

  // Füge ein Produkt zum Warenkorb hinzu
  void addToCart(Product product) {
    cart.add(product);
  }

  // Entferne ein Produkt aus dem Warenkorb
  void removeFromCart(Product product) {
    cart.remove(product);
  }
}
