import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../services/my_app_method.dart';

class HeartButtonWidget extends StatefulWidget {
  const HeartButtonWidget({
    super.key,
    this.size = 25,
    this.color = Colors.transparent,
    required this.productId,
  });
  final double size;
  final Color color;
  final String productId;
  @override
  State<HeartButtonWidget> createState() => _HeartButtonWidgetState();
}

class _HeartButtonWidgetState extends State<HeartButtonWidget> {
  bool isLoading=false;
  @override
  Widget build(BuildContext context) {
    final wishlistProvider=Provider.of<WishlistProvider>(context);
     // final productProvider = Provider.of<ProductProvider>(context);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color,
      ),
      child: IconButton(
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
        ),
        onPressed: () {
          // wishlistProvider.addOrRemoveFromWishlist(productId: widget.productId);
        setState(() {
          isLoading=true;
        });
        try{
          if (wishlistProvider.getWishlistItems.containsKey(widget.productId)) {
            wishlistProvider.removeWishlistItemFromFirebase(
                productId: widget.productId,
                wishlistId: wishlistProvider.getWishlistItems[widget.productId]!.id);
          }else{
            wishlistProvider.addToWishlistFirebase(
                productId: widget.productId, context: context);
          }
        }catch(e){
          if(!mounted)return;
          MyAppMethods.showErrorORWarningDialog(
              context: context,
              subtitle: e.toString(), fct: (){});
        }finally{
          setState(() {
            isLoading=false;
          });
        }
        },
        icon: Icon(
          wishlistProvider.isProductInWishlist(productId: widget.productId)?
          IconlyBold.heart:IconlyLight.heart,
          size: widget.size,
          color: wishlistProvider.isProductInWishlist(productId: widget.productId)?
          Colors.red:Colors.grey,
        ),
      ),
    );
  }
}
