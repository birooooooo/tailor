import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/shop_provider.dart';

/// Lets the shop manager add and remove the styles offered when creating orders.
class StylesScreen extends StatefulWidget {
  const StylesScreen({super.key});

  @override
  State<StylesScreen> createState() => _StylesScreenState();
}

class _StylesScreenState extends State<StylesScreen> {
  final _controller = TextEditingController();
  final _listKey = GlobalKey<AnimatedListState>();
  late List<String> _styles;

  @override
  void initState() {
    super.initState();
    _styles = [...context.read<ShopProvider>().styles];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final shop = context.read<ShopProvider>();
    if (_styles.contains(name)) {
      _controller.clear();
      return;
    }
    shop.addStyle(name);
    setState(() => _styles.add(name));
    _listKey.currentState?.insertItem(
      _styles.length - 1,
      duration: const Duration(milliseconds: 320),
    );
    _controller.clear();
  }

  void _remove(int index) {
    if (_styles.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لانیکەم یەک شێواز دەبێت بمێنێتەوە')),
      );
      return;
    }
    final name = _styles[index];
    context.read<ShopProvider>().removeStyle(name);
    setState(() => _styles.removeAt(index));
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _row(name, animation, null),
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('شێوازەکان')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _add(),
                    decoration: const InputDecoration(
                      hintText: 'ناوی شێوازێکی نوێ',
                      prefixIcon: Icon(Icons.style_outlined, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: _add,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: const Icon(Icons.add_rounded),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _styles.isEmpty
                ? Center(
                    child: Text(
                      'هێشتا شێواز نییە',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: _styles.length,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemBuilder: (context, index, animation) =>
                        _row(_styles[index], animation, index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(String name, Animation<double> animation, int? index) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return SizeTransition(
      sizeFactor: curved,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: curved,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppColors.rSm),
              boxShadow: AppColors.softShadow,
            ),
            child: Row(
              children: [
                Icon(Icons.style_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: index == null ? null : () => _remove(index),
                  icon: Icon(Icons.delete_outline_rounded),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
