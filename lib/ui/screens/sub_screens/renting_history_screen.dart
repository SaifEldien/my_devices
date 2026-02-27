import 'package:my_devices/core/core.dart';

class RentingHistoryScreen extends StatefulWidget {
  final String? deviceId;
  const RentingHistoryScreen({super.key, this.deviceId});

  @override
  State<RentingHistoryScreen> createState() => _RentingHistoryScreenState();
}

class _RentingHistoryScreenState extends State<RentingHistoryScreen> {
  late PageController _pageController;
  late TextEditingController _searchController;
  List<Rent> _allHistory = [];
  List<Rent> _history = [];
  int _currentIndex = 0;
  Device? _currentDevice;
  bool isSearch = false;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _searchController = TextEditingController();

      _loadHistory();

  }




  void _loadHistory() {
    final provider = Provider.of<DeviceProvider>(context, listen: false);
    if (widget.deviceId == null) {
      final allRents = provider.devices.expand((d) => d.rentingHistory).toList();

      allRents.sort((a, b) => DateTime.parse(b.rentStart).compareTo(DateTime.parse(a.rentStart)));

      _allHistory = allRents;
    } else {
      final device = provider.devices.firstWhere((d) => d.id == widget.deviceId);
      _allHistory = device.rentingHistory.reversed.toList();
    }

    _history = List.from(_allHistory);
    _updateCurrentDevice();
  }

  void _updateCurrentDevice() {
    if (_history.isEmpty) {
      _currentDevice = null;
      return;
    }

    final provider = Provider.of<DeviceProvider>(context, listen: false);

    _currentDevice = provider.devices.firstWhere((d) => d.id == _history[_currentIndex].deviceId);
  }

  void _onSearch(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _history = List.from(_allHistory);
      } else {
        final query = value.toLowerCase();
        _history = _allHistory.where((rent) {
          final addressMatch = rent.renterLocation?.address.toLowerCase().contains(query) ?? false;
          final renterMatch = rent.renterName.toLowerCase().contains(query);
          return addressMatch || renterMatch;
        }).toList();
      }

      _currentIndex = 0;
      _updateCurrentDevice();
    });
  }

  void _deleteCurrentRent() {
    if (_history.isEmpty) return;

    final rentId = _history[_currentIndex].id;
    final deviceId = _history[_currentIndex].deviceId;

    final provider = Provider.of<DeviceProvider>(context, listen: false);

    final device = provider.devices.firstWhere((d) => d.id == deviceId);

    device.rentingHistory.removeWhere((rent) => rent.id == rentId);

    provider.updateDevice(device);

    setState(() {
      _history.removeAt(_currentIndex);
      _allHistory.removeWhere((rent) => rent.id == rentId);

      if (_currentIndex >= _history.length) {
        _currentIndex = _history.isEmpty ? 0 : _history.length - 1;
      }

      _updateCurrentDevice();
    });

    if (_history.isEmpty) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: _history.isEmpty
            ? null
            : FloatingActionButton(
                heroTag: "history_delete",
                backgroundColor: Colors.red,
                onPressed: () {
                  showCustomDialog(
                    context,
                    title: "delete_rent".tr(),
                    onAccept: _deleteCurrentRent,
                    icon: Icons.delete_forever,
                    color: Colors.red,
                  );
                },
                child: const Icon(Icons.delete_forever, color: Colors.white),
              ),
        body: CustomScrollView(
          slivers: [
            buildSliverHeader(
              Colors.lightBlue,
              false,
              false,
              addSearch: (){
                isSearch = true;
                setState(() {

                });
              },
              removeSearch: (){
                isSearch = false;
                setState(() {});},
              context,
              _currentDevice,
              isHistory: true,
              isSearch: isSearch,
              searchCont: _searchController,
              onSearch: _onSearch,
            ),
            SliverFillRemaining(
              child: _history.isEmpty
                  ? const Center(child: Text("No renting history"))
                  : Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: _history.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                              _updateCurrentDevice();
                            });
                          },
                          itemBuilder: (context, index) {
                            final rent = _history[index];
                            final isOverdue = rent.remainingRentalDays! < 0;

                            return _HistoryPage(
                              device: _currentDevice!,
                              rent: rent,
                              isOverdue: isOverdue,
                            );
                          },
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildDots(),
                            const SizedBox(height: 20),
                          ],
                        )

                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _history.length,
        (i) => InkWell(
          onTap: () {
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _currentIndex ? 14 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: i == _currentIndex ? Colors.blue : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryPage extends StatelessWidget {
  final Device device;
  final Rent rent;
  final bool isOverdue;
  const _HistoryPage({required this.device, required this.rent, required this.isOverdue});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildDeviceInfo(context, device),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 200),
                    child: buildRenterCard(rent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          buildRentalCard(context, rent, isOverdue),
          const SizedBox(height: 16),
          buildMapPreview(device),
        ],
      ),
    );
  }
}
