import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/extensions/build_context_ext.dart';

/// Main Screen - Equipment List with Tabs (와이어프레임 기준)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _selectedSortIndex = 0;

  final List<String> _sortOptions = [
    '거리순',
    '가격순',
    '평점순',
  ];

  // Mock equipment data
  final List<Map<String, dynamic>> _equipmentList = [
    {
      'id': '1',
      'name': '콤바인',
      'supplier': '김기계',
      'price': '80,000',
      'rating': 4.8,
      'reviewCount': 25,
      'distance': '2.3',
      'type': '이동형',
      'icon': '🚜',
    },
    {
      'id': '2',
      'name': '트랙터',
      'supplier': '이농부',
      'price': '60,000',
      'rating': 4.9,
      'reviewCount': 32,
      'distance': '4.1',
      'type': '이동형',
      'icon': '🚜',
    },
    {
      'id': '3',
      'name': '고추건조기',
      'supplier': '박시설',
      'price': '50,000',
      'rating': 4.7,
      'reviewCount': 28,
      'distance': '5.8',
      'type': '고정형',
      'icon': '🏭',
    },
    {
      'id': '4',
      'name': '저온저장고',
      'supplier': '정보관',
      'price': '45,000',
      'rating': 4.6,
      'reviewCount': 19,
      'distance': '3.5',
      'type': '고정형',
      'icon': '🏭',
    },
    {
      'id': '5',
      'name': '이앙기',
      'supplier': '최농기',
      'price': '75,000',
      'rating': 4.5,
      'reviewCount': 22,
      'distance': '6.2',
      'type': '이동형',
      'icon': '🚜',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정렬',
              style: context.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            ..._sortOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return ListTile(
                title: Text(option),
                trailing: _selectedSortIndex == index
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedSortIndex = index;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 헤더: ☰ 메뉴 + "단감" + 👤 프로필
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('메뉴 버튼')),
            );
          },
        ),
        title: Text(
          '단감',
          style: context.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프로필')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 검색바
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '필요한 장비를 검색하세요',
                  border: InputBorder.none,
                ),
              ),
            ),

            // 필터/정렬 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('필터')),
                      );
                    },
                    icon: const Icon(Icons.tune),
                    label: const Text('필터'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _showSortBottomSheet,
                    icon: const Icon(Icons.unfold_more),
                    label: Text(_sortOptions[_selectedSortIndex]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 탭바
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '이동형'),
                Tab(text: '고정형'),
              ],
            ),

            // 탭 뷰
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEquipmentListView(
                    _equipmentList
                        .where((e) => e['type'] == '이동형')
                        .toList(),
                  ),
                  _buildEquipmentListView(
                    _equipmentList
                        .where((e) => e['type'] == '고정형')
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentListView(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64),
            const SizedBox(height: 16),
            const Text('검색 결과가 없습니다.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('검색 조건 변경'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final equipment = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(equipment['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('공급자: ${equipment['supplier']}'),
                Text('${equipment['rating']} (${equipment['reviewCount']}리뷰) | ${equipment['distance']}km'),
                Text('가격: ₩${equipment['price']}/시간'),
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${equipment['name']} 상세보기')),
              );
            },
          ),
        );
      },
    );
  }
}
