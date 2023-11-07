// import 'package:extended_image/extended_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/colors.dart';

class NetworkImageWidget extends StatelessWidget {

  final String? imageUrl;
  final double? height;
  final double? width;
  final bool? isVideoFeed;
  final Color? color;
  final BoxFit? fit;
  final IconData? errorIcon;
  final BorderRadius borderRadius;
  const NetworkImageWidget({
    Key? key,
    this.height,
    this.width,
    this.errorIcon,
    this.color,
    this.isVideoFeed,
    this.fit,
    this.imageUrl,
    this.borderRadius = BorderRadius.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        key: ValueKey(imageUrl.toString()),
        fit: fit ?? BoxFit.cover,
        height: height,
        maxWidthDiskCache: 350,
        memCacheWidth: 350,
        cacheKey: imageUrl.toString(),
        width: width,
        filterQuality: FilterQuality.low,
        color: color,
        useOldImageOnUrlChange: true,
        fadeOutDuration: const Duration(milliseconds: 0),
        fadeOutCurve: Curves.easeInOut,
        fadeInDuration: const Duration(microseconds: 0),
        fadeInCurve: Curves.easeIn,
        imageUrl: imageUrl.toString(),
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return Shimmer.fromColors(
              baseColor: isVideoFeed != null && isVideoFeed!
                  ? primaryBlack
                  : Colors.grey[300]!,
              highlightColor: isVideoFeed != null && isVideoFeed!
                  ? primaryBlack
                  : Colors.grey[100]!,
              child: Container(
                color: Colors.white,
              ));
          //    Center(
          //   child: Lottie.asset(
          //     'assets/json/loader.json',
          //     height: 100,
          //     width: 100,
          //   ),
          // );
        },
        errorWidget: (context, url, error) {
          return ColoredBox(
              child: Center(
                  child: Icon(
                errorIcon ?? CupertinoIcons.profile_circled,
                size: 20,
                color: greyColor,
              )
                  ),
                  color: greyBorderColor)
              ;
        },
      ),
    );
  }
}
