import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomCarousel extends StatefulWidget {
  final List<Widget> items;
  final Duration autoPlayDuration;
  final bool autoPlay;
  final bool enableInfiniteScroll;
  final bool showIndicator;
  final IndicatorStyle indicatorStyle;
  final double viewportFraction;
  final double aspectRatio;
  final Curve curve;
  final bool enlargeCenterPage;
  final double enlargeFactor;
  final bool pauseAutoPlayOnTouch;
  final bool animated;
  final CarouselStyle style;
  final EdgeInsets? padding;
  final ValueChanged<int>? onPageChanged;

  const CustomCarousel({
    super.key,
    required this.items,
    this.autoPlayDuration = const Duration(seconds: 3),
    this.autoPlay = true,
    this.enableInfiniteScroll = true,
    this.showIndicator = true,
    this.indicatorStyle = IndicatorStyle.dots,
    this.viewportFraction = 1.0,
    this.aspectRatio = 16 / 9,
    this.curve = Curves.easeInOut,
    this.enlargeCenterPage = false,
    this.enlargeFactor = 0.2,
    this.pauseAutoPlayOnTouch = true,
    this.animated = true,
    this.style = CarouselStyle.standard,
    this.padding,
    this.onPageChanged,
  });

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: widget.enableInfiniteScroll ? widget.items.length * 100 : 0,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: widget.autoPlayDuration,
    );

    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (!widget.autoPlay || _isAutoPlaying) return;
    _isAutoPlaying = true;
    _animationController.repeat();
    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        _animationController.reset();
        _nextPage();
      }
    });
  }

  void _stopAutoPlay() {
    if (!_isAutoPlaying) return;
    _isAutoPlaying = false;
    _animationController.stop();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: widget.curve,
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = widget.enableInfiniteScroll
          ? page % widget.items.length
          : page.clamp(0, widget.items.length - 1);
    });
    widget.onPageChanged?.call(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: GestureDetector(
            onPanDown: widget.pauseAutoPlayOnTouch ? (_) => _stopAutoPlay() : null,
            onPanCancel: widget.pauseAutoPlayOnTouch ? _startAutoPlay : null,
            onPanEnd: widget.pauseAutoPlayOnTouch ? (_) => _startAutoPlay() : null,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final itemIndex = widget.enableInfiniteScroll
                    ? index % widget.items.length
                    : index;
                Widget item = widget.items[itemIndex];

                if (widget.style == CarouselStyle.card) {
                  item = _buildCardItem(item);
                }

                if (widget.animated) {
                  item = AnimatedWidget(
                    fadeIn: true,
                    scale: true,
                    child: item,
                  );
                }

                return Transform.scale(
                  scale: widget.enlargeCenterPage
                      ? _getScale(index == _currentPage)
                      : 1.0,
                  child: Padding(
                    padding: widget.padding ?? EdgeInsets.zero,
                    child: item,
                  ),
                );
              },
              itemCount: widget.enableInfiniteScroll
                  ? null
                  : widget.items.length,
            ),
          ),
        ),
        if (widget.showIndicator) ...[
          const SizedBox(height: 16),
          _buildIndicator(),
        ],
      ],
    );
  }

  Widget _buildCardItem(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildIndicator() {
    switch (widget.indicatorStyle) {
      case IndicatorStyle.dots:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => _buildDot(index),
          ),
        );
      case IndicatorStyle.numbers:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_currentPage + 1}/${widget.items.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      case IndicatorStyle.bars:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => _buildBar(index),
          ),
        );
    }
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primaryColor
            : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildBar(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 4,
      width: 16,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primaryColor
            : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  double _getScale(bool isCurrent) {
    return isCurrent ? 1.0 : (1.0 - widget.enlargeFactor);
  }
}

enum IndicatorStyle {
  dots,
  numbers,
  bars,
}

enum CarouselStyle {
  standard,
  card,
}

// Image Carousel
class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final double aspectRatio;
  final BoxFit fit;
  final bool showIndicator;
  final bool autoPlay;
  final Duration autoPlayDuration;
  final bool enableInfiniteScroll;
  final CarouselStyle style;
  final bool animated;
  final Widget Function(String imageUrl)? imageBuilder;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.cover,
    this.showIndicator = true,
    this.autoPlay = true,
    this.autoPlayDuration = const Duration(seconds: 3),
    this.enableInfiniteScroll = true,
    this.style = CarouselStyle.standard,
    this.animated = true,
    this.imageBuilder,
    this.errorWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCarousel(
      items: imageUrls.map((url) {
        if (imageBuilder != null) {
          return imageBuilder!(url);
        }
        return Image.network(
          url,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ??
                const Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return loadingWidget ??
                const Center(
                  child: CircularProgressIndicator(),
                );
          },
        );
      }).toList(),
      aspectRatio: aspectRatio,
      showIndicator: showIndicator,
      autoPlay: autoPlay,
      autoPlayDuration: autoPlayDuration,
      enableInfiniteScroll: enableInfiniteScroll,
      style: style,
      animated: animated,
    );
  }
}
