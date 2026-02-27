import '../core.dart';

class CustomImagePageview extends StatefulWidget {
  final List imagesPaths;
  final double? width;
  final double? height;
  final double? top;
  final double? right;
  final bool? isRounded;
  const CustomImagePageview({
    super.key,
    required this.imagesPaths,
    this.width,
    this.height,
    this.top,
    this.right,
    this.isRounded,
  });

  @override
  State<CustomImagePageview> createState() => _CustomImagePageviewState();
}

class _CustomImagePageviewState extends State<CustomImagePageview> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return PageView(
      onPageChanged: (i) {
        currentPage = i;
        setState(() {});
      },
      children: widget.imagesPaths.isNotEmpty
          ? widget.imagesPaths.map((path) {
              return Stack(
                children: [
                  InkWell(
                    onTap: (){
                      if (widget.height==600) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            body: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomAppBar(title: "images".tr()),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: SizedBox(
                                    height: 600,
                                    width: 500,
                                    child: CustomImagePageview(
                                      imagesPaths: widget.imagesPaths,
                                      right: 5,
                                      height: 600,
                                      width: 500,
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: SmartImage(
                      path: path,
                      width: widget.width ?? 120,
                      height: widget.height ?? 120,
                      isRounded: widget.isRounded ?? true,
                    ),
                  ),
                  if (widget.imagesPaths.length > 1)
                    Container(
                      margin: EdgeInsets.only(top: widget.top??5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: Text(
                              '${currentPage + 1}/${widget.imagesPaths.length}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: widget.right,),
                        ],
                      ),
                    ),
                ],
              );
            }).toList()
          : [
              SmartImage(
                path: "assets/images/fallbackImage.jpg",
                width: widget.width ?? 120,
                height: widget.height ?? 120,
                isRounded: widget.isRounded ?? true,
              ),
            ],
    );
  }
}

class SmartImage extends StatelessWidget {
  final String path;
  final double width;
  final double height;
  final bool? isRounded;
  const SmartImage({super.key, required this.path, required this.width, required this.height, this.isRounded});
  bool _isNetworkPath(String path) {
    final uri = Uri.tryParse(path);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetworkPath(path)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(isRounded==false ?0 : 16),
        child: Image.network(
          path,
          width: width,
          height: height,
          fit: BoxFit.fill,
          errorBuilder: (_, _, _) =>
              Image.asset("assets/images/fallbackImage.jpg", width: width, height: height, fit: BoxFit.fill),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(isRounded==false ?0 : 16),
      child: Image.file(
        File(path),
        width: width,
        height: height,
        fit: BoxFit.fill,
        errorBuilder: (_, _, _) =>
            Image.asset("assets/images/fallbackImage.jpg", width: width, height: height, fit: BoxFit.fill),
      ),
    );
  }
}
