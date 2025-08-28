
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../widgets/view_image_screen.dart';

class PromotionCarouselSlider extends StatefulWidget {
  const PromotionCarouselSlider({super.key});

  @override
  State<PromotionCarouselSlider> createState() => _PromotionCarouselSliderState();
}

class _PromotionCarouselSliderState extends State<PromotionCarouselSlider> {
  final List<String> imgList = [
    "https://picsum.photos/id/1011/800/400",
    "https://picsum.photos/id/1012/800/400",
    "https://picsum.photos/id/1013/800/400",
    "https://picsum.photos/id/1014/800/400",
    "https://picsum.photos/id/1015/800/400",
  ];

  int activeIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CarouselSlider.builder(
            carouselController: _controller,
            itemCount: imgList.length,
            itemBuilder: (context, index, realIndex) {
              final urlImage = imgList[index];
              return InkWell(
                onTap: (){
                  //showTopImageDialog(context,imgList[activeIndex]);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCarosuleImage(imagePath: imgList[index],)));
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    //image: DecorationImage( image: NetworkImage(urlImage), fit: BoxFit.cover, ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      urlImage,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // ✅ return child when fully loaded
                        }
                        return const SizedBox(
                          height: 60,
                          width: 60,
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.green),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/no-image.png",
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),

                  /* FadeInImage.assetNetwork(
                    placeholder: "assets/images/no-image.png",
                    image: urlImage,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        height: 100,
                          width: 60,
                          child: Image.asset("assets/images/no-image.png",));
                    },
                  )*/
                  /*Image.network(
                    urlImage,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null)
                        , fit: BoxFit.cover); // loaded
                      return Image.asset("assets/images/no-image.png", fit: BoxFit.cover);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset("assets/images/no-image.png", fit: BoxFit.cover);
                    },
                  ),*/

                  ),
                );
            },
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              viewportFraction: 0.8,
              onPageChanged: (index, reason) =>
                  setState(() => activeIndex = index),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSmoothIndicator(
            activeIndex: activeIndex,
            count: imgList.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Colors.green,
              dotColor: Colors.grey,
            ),
            onDotClicked: (index) {
              _controller.animateToPage(index);
            },
          ),
        ],
      ),
    );
  }
  Future<void> showTopImageDialog(BuildContext context, String imagePath) async {
    return showDialog(
      context: context,
      barrierDismissible: true, // tap outside to dismiss
      builder: (context) {
        return Align(
          alignment: Alignment.topCenter, // 👈 Align dialog at top
          child: Padding(
            padding: const EdgeInsets.only(top: 60), // adjust distance from top
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 1.toWidthPercent(),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imagePath,fit: BoxFit.cover,)
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}