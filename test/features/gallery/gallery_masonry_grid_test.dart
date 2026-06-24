import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/gallery/presentation/widgets/gallery_masonry_grid.dart';

void main() {
  test('distributeToShortestColumns balances three columns', () {
    final columns = distributeToShortestColumns(
      itemCount: 6,
      columnCount: 3,
      aspectRatios: const [1, 1, 1],
    );

    expect(columns, hasLength(3));
    expect(columns.expand((c) => c).length, 6);
    expect(columns.every((c) => c.length == 2), isTrue);
  });

  test('distributeToShortestColumns returns empty for zero items', () {
    expect(
      distributeToShortestColumns(itemCount: 0, columnCount: 3),
      isEmpty,
    );
  });
}
