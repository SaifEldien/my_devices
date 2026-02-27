import  'package:my_devices/core/core.dart';

Widget buildImagePreviewList({required List imagesPaths, required Function onAddMore, required Function setState}) {
  return SizedBox(
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imagesPaths.length + 1,
      itemBuilder: (context, index) {
        if (index == imagesPaths.length) {
          return InkWell(
            onTap: () {
              onAddMore();
            },
            child: buildAddMoreButton(),
          );
        }
        final path = imagesPaths[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Stack(
            children: [
              InkWell(
                onTap: () {
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
                                    imagesPaths: [path],
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
                  child: SmartImage(path: path, width: 100, height: 100)),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () {
                    imagesPaths.removeAt(index);
                    setState();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget buildEmptyImageState(String title) {
  return Container(
    height: 100,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: Colors.grey,
        width: 1,
        style: BorderStyle.solid,
      ), // Dash effect handled by logic usually
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.camera_alt_outlined, color: Colors.purple.shade100, size: 40),
        SizedBox(height: 8),
        Text(title),
      ],
    ),
  );
}

Widget buildAddMoreButton() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8.0),
    width: 100,
    decoration: BoxDecoration(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey,width: 1.5),
    ),
    child: Icon(Icons.add, size: 40, color: Colors.purple.shade100),
  );
}