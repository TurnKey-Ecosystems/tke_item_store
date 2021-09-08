part of tke_item_store;

class ${fileBasenameNoExtension} extends Page {
  ${fileBasenameNoExtension}() : super(
    icon: F_UI.Icons.home_filled,
    loadingMessage: "Loading ${fileBasenameNoExtension}...",
    appBarBuilder: AppBar.text("${fileBasenameNoExtension}").build,
    getShouldShowPage: () {
      return true;
    },
    reloadTriggers: [],
  );

  @override
  F_UI.Widget? getPageBody(F_UI.BuildContext context) {
    return Box(
      width: AxisSize.growToFillSpace(),
      height: AxisSize.shrinkToFitContents(),
      mainAxis: Axis.VERTICAL,
      childToBoxSpacing: ChildToBoxSpacing.topCenter(
        padding_tu: 7,
      ),
      childToChildSpacingVertical:
        ChildToChildSpacing.uniformPaddingTU(7),
      children: [
        // Add a title
        Text.heading(() => "${fileBasenameNoExtension}"),

        // Add a description
        Text.body(() => "This page is empty."),
      ],
    );
  }
}


