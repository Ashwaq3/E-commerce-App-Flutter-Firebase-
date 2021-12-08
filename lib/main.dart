import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcan/providers/cart.dart';
import 'package:youcan/providers/orders.dart';
import 'package:youcan/providers/products.dart';
import 'package:youcan/screens/auth_screen.dart';
import 'package:youcan/screens/splash_screen.dart';
import './providers/auth.dart';
import './screens/cart_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/orders_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/user_products_screen.dart';
import './screens/product_overview_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        //Proxy Provider is used when one provider depend on the other
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (ctx, authValue, previousOrders) => previousOrders!
            ..getData(
              authValue.token,
              authValue.userId,
              previousOrders.orders,
            ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products(),
            update: (ctx, authValue, previousProduct) => previousProduct!
              ..getData(
                authValue.token,
                authValue.userId,
                previousProduct.items,
              )),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Shop',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: Colors.pink,
              primaryColor: Colors.lightBlueAccent,
              fontFamily: 'Lato'),
          home: auth.isAuth
              ? const ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.autoLogIn(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (_) => const ProductDetailScreen(),
            CartScreen.routeName: (_) => const CartScreen(),
            EditProductScreen.routeName: (_) => const EditProductScreen(),
            UserProductsScreen.routeName: (_) => const UserProductsScreen(),
            OrderScreen.routeName: (_) => const OrderScreen(),
          },
        ),
      ),
    );
  }
}
