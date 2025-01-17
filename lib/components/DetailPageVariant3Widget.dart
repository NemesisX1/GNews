import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:gnews/main.dart';
import 'package:gnews/models/DashboardResponse.dart';
import 'package:gnews/network/RestApis.dart';
import 'package:gnews/screens/CommentListScreen.dart';
import 'package:gnews/screens/LoginScreen.dart';
import 'package:gnews/utils/Colors.dart';
import 'package:gnews/utils/Common.dart';
import 'package:gnews/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';

import '../AppLocalizations.dart';
import 'AppWidgets.dart';
import 'BreakingNewsListWidget.dart';
import 'CommentTextWidget.dart';
import 'HtmlWidget.dart';
import 'ReadAloudDialog.dart';

// ignore: must_be_immutable
class DetailPageVariant3Widget extends StatefulWidget {
  static String tag = '/DetailPageVariant3Widget';

  NewsData newsData;
  final int postView;
  final String postContent;
  final List<NewsData> relatedNews;

  DetailPageVariant3Widget(this.newsData,
      {this.postView, this.postContent, this.relatedNews});

  @override
  DetailPageVariant3WidgetState createState() =>
      DetailPageVariant3WidgetState();
}

class DetailPageVariant3WidgetState extends State<DetailPageVariant3Widget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setDynamicStatusBarColorDetail(milliseconds: 400);
  }

  Future<void> addToWishList() async {
    Map req = {
      'post_id': widget.newsData.iD,
    };

    if (!widget.newsData.is_fav.validate()) {
      addWishList(req).then((res) {
        appStore.isLoading = false;

        LiveStream().emit(refreshBookmark, true);

        toast(res['message']);
      }).catchError((error) {
        appStore.isLoading = false;
        toast(error.toString());
      });
    } else {
      removeWishList(req).then((res) {
        appStore.isLoading = false;

        LiveStream().emit(refreshBookmark, true);

        toast(res.message.validate());
      }).catchError((error) {
        appStore.isLoading = false;
        toast(error.toString());
      });
    }

    widget.newsData.is_fav = !widget.newsData.is_fav.validate();
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);

    return Container(
      child: Stack(
        children: [
          cachedImage(widget.newsData.image.validate(),
              height: context.height(), fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(color: Colors.black26),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 8, right: 8, top: 24, bottom: 80),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              child: BackButton(),
                              decoration: BoxDecoration(
                                  color: context.scaffoldBackgroundColor,
                                  shape: BoxShape.circle),
                            ),
                            8.width,
                            Icon(Icons.access_time_rounded,
                                color: Colors.white, size: 16),
                            4.width,
                            Text(widget.newsData.human_time_diff.validate(),
                                style: secondaryTextStyle(color: Colors.white)),
                            4.width,
                            Text('・',
                                style: secondaryTextStyle(color: Colors.white)),
                            Text(
                                    getArticleReadTime(
                                        context,
                                        widget.newsData.post_content
                                            .validate()),
                                    style:
                                        secondaryTextStyle(color: Colors.white))
                                .expand(),
                          ],
                        ).expand(),
                        Row(
                          children: [
                            IconButton(
                              icon: Container(
                                child: Icon(widget.newsData.is_fav.validate()
                                    ? FontAwesome.bookmark
                                    : FontAwesome.bookmark_o),
                                decoration: BoxDecoration(
                                    color: context.scaffoldBackgroundColor,
                                    shape: BoxShape.circle),
                                padding: EdgeInsets.all(4),
                              ),
                              onPressed: () async {
                                if (!appStore.isLoggedIn) {
                                  bool res = await LoginScreen(isNewTask: false)
                                      .launch(context);
                                  if (res ?? false) {
                                    addToWishList();
                                  }
                                } else {
                                  addToWishList();
                                }
                              },
                            ),
                            IconButton(
                              icon: Container(
                                child: Icon(Icons.share_rounded),
                                decoration: BoxDecoration(
                                    color: context.scaffoldBackgroundColor,
                                    shape: BoxShape.circle),
                                padding: EdgeInsets.all(4),
                              ),
                              onPressed: () async {
                                Share.share(
                                    widget.newsData.share_url.validate());
                              },
                            ),
                            IconButton(
                              icon: Container(
                                child: Icon(Icons.play_circle_outline),
                                decoration: BoxDecoration(
                                    color: context.scaffoldBackgroundColor,
                                    shape: BoxShape.circle),
                                padding: EdgeInsets.all(4),
                              ),
                              onPressed: () async {
                                showInDialog(
                                  context,
                                  child: ReadAloudDialog(
                                      parseHtmlString(widget.postContent)),
                                  contentPadding: EdgeInsets.zero,
                                  barrierDismissible: false,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    16.height,
                    if (widget.newsData.category.validate().isNotEmpty)
                      getPostCategoryTagWidget(context, widget.newsData)
                          .withSize(height: 40, width: context.width())
                          .paddingLeft(8),
                    Text(parseHtmlString(widget.newsData.post_title.validate()),
                            style: boldTextStyle(
                                size: 40,
                                fontFamily: titleFont(),
                                color: Colors.white))
                        .paddingOnly(left: 8, right: 8),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesome.commenting_o,
                                size: 16, color: Colors.white),
                            8.width,
                            CommentTextWidget(
                                text: widget.newsData.no_of_comments_text
                                    .validate(value: '0'),
                                textColor: Colors.white),
                          ],
                        )
                            .paddingOnly(left: 8, right: 8, top: 8, bottom: 8)
                            .onTap(() async {
                          await CommentListScreen(widget.newsData.iD)
                              .launch(context);
                          await Future.delayed(Duration(milliseconds: 300));

                          setStatusBarColor(Colors.transparent);
                        }),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesome.eye,
                                size: 16, color: Colors.white),
                            8.width,
                            Text(widget.postView.validate().toString(),
                                style: secondaryTextStyle(color: Colors.white)),
                          ],
                        ).paddingOnly(left: 8, right: 8, top: 8, bottom: 8),
                      ],
                    ),
                    HtmlWidget(
                        postContent: widget.postContent, color: Colors.white),
                    30.height,
                    AppButton(
                      text: appLocalization.translate('view_Comments'),
                      color: appStore.isDarkMode
                          ? scaffoldSecondaryDark
                          : colorPrimary,
                      textStyle: boldTextStyle(color: white),
                      onTap: () async {
                        await CommentListScreen(widget.newsData.iD)
                            .launch(context);
                        await Future.delayed(Duration(milliseconds: 300));

                        setDynamicStatusBarColorDetail(milliseconds: 400);
                      },
                      width: context.width(),
                    ).paddingSymmetric(horizontal: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: 8, right: 8, top: 4, bottom: 4),
                          margin: EdgeInsets.only(left: 16, top: 32, bottom: 8),
                          decoration: BoxDecoration(
                              color: colorPrimary,
                              borderRadius: radius(defaultRadius)),
                          child: Text(appLocalization.translate('related_news'),
                              style: boldTextStyle(
                                  size: 12,
                                  color: Colors.white,
                                  letterSpacing: 1.5)),
                        ),
                        BreakingNewsListWidget(widget.relatedNews.validate()),
                      ],
                    ).visible(widget.relatedNews.validate().isNotEmpty),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
