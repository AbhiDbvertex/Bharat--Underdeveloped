import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension SizeRatios on num {

  double toWidthPercent() {
    Size size = MediaQuery.sizeOf(Get.context!);
    return min(size.width, size.height) * this;
  }

}