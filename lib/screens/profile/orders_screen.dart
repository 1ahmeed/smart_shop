import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_shop/models/order_model.dart';
import 'package:smart_shop/providers/order_provider.dart';
import 'package:smart_shop/screens/root_screen.dart';
import '../../../core/widgets/empty_bag.dart';
import '../../core/services/assets_manager.dart';
import '../../core/widgets/title_text.dart';
import 'widgets/orders_widget.dart';

class OrdersScreenFree extends StatefulWidget {
  static const routeName = '/OrderScreen';

  const OrdersScreenFree({Key? key}) : super(key: key);

  @override
  State<OrdersScreenFree> createState() => _OrdersScreenFreeState();
}

class _OrdersScreenFreeState extends State<OrdersScreenFree> {
  bool isEmptyOrders = false;
  @override
  Widget build(BuildContext context) {
    final orderProvider=Provider.of<OrdersProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const TitlesTextWidget(
            label: 'Placed orders',
          ),
        ),
        body: FutureBuilder<List<OrdersModelAdvanced>>(
          future:orderProvider.fetchOrder() ,
          builder: (context, snapshot) {
            if(snapshot.connectionState==ConnectionState.waiting){
             return const Center(child: CircularProgressIndicator());
            }
            else  if(snapshot.hasError){
             return  Center(child: SelectableText("an error has been occurred ${snapshot.error}"));
            } else if(!snapshot.hasData || orderProvider.getOrders.isEmpty){
              return  EmptyBagWidget(
                  imagePath: AssetsManager.orderBag,
                  function: (){
                    Navigator.pushReplacementNamed(context, RootScreen.routName);
                  },
                  title: "No orders has been placed yet",
                  subtitle: "",
                  buttonText: "Shop now");
            }
            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, index) {
                return  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                  child: OrdersWidgetFree(
                    ordersModelAdvanced: orderProvider.getOrders[index],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            );
          },
        )

    );
  }
}
