import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool animated;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.showBackButton = true,
    this.onBackPressed,
    this.bottom,
    this.leading,
    this.animated = true,
    this.systemOverlayStyle,
  }) : assert(title == null || titleWidget == null,
            'Cannot provide both title and titleWidget');

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton && canPop) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      );
    }

    Widget? titleContent;
    if (titleWidget != null) {
      titleContent = titleWidget;
    } else if (title != null) {
      titleContent = Text(
        title!,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final appBar = AppBar(
      title: animated && titleContent != null
          ? AnimatedWidget(
              child: titleContent,
              fadeIn: true,
              slide: true,
              slideOffset: const Offset(0, -0.2),
            )
          : titleContent,
      leading: animated && leadingWidget != null
          ? AnimatedWidget(
              child: leadingWidget,
              fadeIn: true,
              slide: true,
              slideOffset: const Offset(-0.2, 0),
            )
          : leadingWidget,
      actions: animated && actions != null
          ? List.generate(
              actions!.length,
              (index) => AnimatedWidget(
                child: actions![index],
                fadeIn: true,
                slide: true,
                slideOffset: const Offset(0.2, 0),
                delay: Duration(milliseconds: 100 * index),
              ),
            )
          : actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black87,
      elevation: elevation,
      systemOverlayStyle: systemOverlayStyle ??
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                (backgroundColor?.computeLuminance() ?? 1) > 0.5
                    ? Brightness.dark
                    : Brightness.light,
          ),
      bottom: bottom,
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: appBar,
    );
  }
}

class CustomSliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double expandedHeight;
  final Widget? background;
  final Widget? leading;
  final bool pinned;
  final bool floating;
  final bool snap;
  final bool stretch;
  final double? collapsedHeight;
  final Widget? bottom;
  final bool animated;

  const CustomSliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.expandedHeight = 200,
    this.background,
    this.leading,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.stretch = false,
    this.collapsedHeight,
    this.bottom,
    this.animated = true,
  }) : assert(title == null || titleWidget == null,
            'Cannot provide both title and titleWidget');

  @override
  Widget build(BuildContext context) {
    Widget? titleContent;
    if (titleWidget != null) {
      titleContent = titleWidget;
    } else if (title != null) {
      titleContent = Text(
        title!,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      stretch: stretch,
      collapsedHeight: collapsedHeight,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black87,
      elevation: 0,
      leading: animated && leading != null
          ? AnimatedWidget(
              child: leading!,
              fadeIn: true,
              slide: true,
              slideOffset: const Offset(-0.2, 0),
            )
          : leading,
      actions: animated && actions != null
          ? List.generate(
              actions!.length,
              (index) => AnimatedWidget(
                child: actions![index],
                fadeIn: true,
                slide: true,
                slideOffset: const Offset(0.2, 0),
                delay: Duration(milliseconds: 100 * index),
              ),
            )
          : actions,
      centerTitle: centerTitle,
      title: animated && titleContent != null
          ? AnimatedWidget(
              child: titleContent,
              fadeIn: true,
              slide: true,
              slideOffset: const Offset(0, -0.2),
            )
          : titleContent,
      flexibleSpace: background != null
          ? FlexibleSpaceBar(
              background: animated
                  ? AnimatedWidget(
                      child: background!,
                      fadeIn: true,
                      scale: true,
                      scaleBegin: 1.1,
                    )
                  : background,
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
            )
          : null,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: animated
                  ? AnimatedWidget(
                      child: bottom!,
                      fadeIn: true,
                      slide: true,
                      slideOffset: const Offset(0, 0.2),
                    )
                  : bottom!,
            )
          : null,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            (backgroundColor?.computeLuminance() ?? 1) > 0.5
                ? Brightness.dark
                : Brightness.light,
      ),
    );
  }
}
