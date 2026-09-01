import '../models/order_request.dart';
import '../models/owner_profile.dart';
import '../models/product.dart';

const demoOwnerId = 'demo-owner';
const demoShopSlug = 'whimsical';

OwnerProfile get demoOwner => OwnerProfile(
      id: demoOwnerId,
      shopName: 'Whimsical',
      shopSlug: demoShopSlug,
      bio:
          'Hand-finished inhaler charms with tiny dinosaur keychains — made in small batches for pockets, bags, and little everyday joys.',
      contactInfo: const {
        'instagram': '@whimsical.charms',
        'facebook': 'Whimsical Charms',
        'gcash': '09XX XXX XXXX',
      },
    );

List<ProductOption> get _demoCords => const [
      ProductOption(
        id: 'cord-mint',
        name: 'Mint paracord',
        price: 40,
        imageUrl: 'asset:assets/products/baby_rex.svg',
        stock: 8,
      ),
      ProductOption(
        id: 'cord-blush',
        name: 'Blush paracord',
        price: 40,
        imageUrl: 'asset:assets/products/pastel_ptero.svg',
        stock: 8,
      ),
      ProductOption(
        id: 'cord-sky',
        name: 'Sky paracord',
        price: 40,
        imageUrl: 'asset:assets/products/cloud_trice.svg',
        stock: 6,
      ),
    ];

List<ProductOption> get _demoTrinkets => const [
      ProductOption(
        id: 't-rex',
        name: 'Baby Rex',
        price: 80,
        imageUrl: 'asset:assets/products/baby_rex.svg',
        stock: 5,
      ),
      ProductOption(
        id: 't-stego',
        name: 'Sleepy Stego',
        price: 80,
        imageUrl: 'asset:assets/products/sleepy_stego.svg',
        stock: 5,
      ),
      ProductOption(
        id: 't-star',
        name: 'Tiny Star',
        price: 35,
        imageUrl: 'asset:assets/doodles/doodle_sparkle.svg',
        stock: 12,
      ),
      ProductOption(
        id: 't-heart',
        name: 'Heart charm',
        price: 35,
        imageUrl: 'asset:assets/doodles/doodle_heart.svg',
        stock: 12,
      ),
    ];

List<Product> demoProducts() {
  final now = DateTime.now();
  return [
    Product(
      id: 'p-baby-rex',
      ownerId: demoOwnerId,
      name: 'Baby Rex Inhaler Keychain',
      description:
          'A mint-speckled rescue inhaler sleeve with a chubby baby T-rex charm. Clip it to a bag or keep it on the original case — the dino stays put.',
      price: 450,
      compareAtPrice: 520,
      imageUrls: const ['asset:assets/products/baby_rex.svg'],
      category: 'Dino Series',
      paracords: _demoCords,
      trinkets: _demoTrinkets,
      stockStatus: StockStatus.available,
      isPublished: true,
      sortOrder: 0,
      createdAt: now.subtract(const Duration(days: 12)),
      updatedAt: now,
    ),
    Product(
      id: 'p-sleepy-stego',
      ownerId: demoOwnerId,
      name: 'Sleepy Stego Puff',
      description:
          'Soft yolk enamel and a drowsy stegosaurus who would like you to take your puff, then nap. Slightly oversized charm, very huggable.',
      price: 480,
      imageUrls: const ['asset:assets/products/sleepy_stego.svg'],
      category: 'Dino Series',
      paracords: _demoCords,
      trinkets: _demoTrinkets,
      stockStatus: StockStatus.madeToOrder,
      isPublished: true,
      sortOrder: 1,
      createdAt: now.subtract(const Duration(days: 9)),
      updatedAt: now,
    ),
    Product(
      id: 'p-pastel-ptero',
      ownerId: demoOwnerId,
      name: 'Pastel Ptero Set',
      description:
          'A matching pair: inhaler jacket plus a pterodactyl that actually flies (off your zipper). Lilac and petal, because of course.',
      price: 620,
      compareAtPrice: 690,
      imageUrls: const ['asset:assets/products/pastel_ptero.svg'],
      category: 'Pastel Series',
      paracords: _demoCords,
      trinkets: _demoTrinkets,
      stockStatus: StockStatus.available,
      isPublished: true,
      sortOrder: 2,
      createdAt: now.subtract(const Duration(days: 6)),
      updatedAt: now,
    ),
    Product(
      id: 'p-cloud-trice',
      ownerId: demoOwnerId,
      name: 'Cloud Trice Charm',
      description:
          'Sky-blue jacket, a triceratops with a cloud ruff, and a yolk star on the clip. Restocking soon — still worth a look.',
      price: 430,
      imageUrls: const ['asset:assets/products/cloud_trice.svg'],
      category: 'Pastel Series',
      paracords: _demoCords,
      trinkets: _demoTrinkets,
      stockStatus: StockStatus.soldOut,
      isPublished: true,
      sortOrder: 3,
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now,
    ),
  ];
}

List<OrderRequest> demoOrders() {
  final now = DateTime.now();
  return [
    OrderRequest(
      id: 'o-demo-1',
      shopSlug: demoShopSlug,
      customerName: 'Mika Santos',
      customerContact: '09XX 555 0142',
      items: const [
        OrderItem(
          productId: 'p-baby-rex',
          productName: 'Baby Rex Inhaler Keychain',
          variantSelection: {'paracord': 'Mint paracord', 'trinkets': 'Baby Rex'},
          quantity: 1,
          priceAtOrder: 570,
          paracord: {'id': 'cord-mint', 'name': 'Mint paracord', 'price': 40},
          trinkets: [
            {'id': 't-rex', 'name': 'Baby Rex', 'price': 80},
          ],
        ),
      ],
      totalAmount: 570,
      customerNote: 'Can you pack it as a gift?',
      status: OrderStatus.newRequest,
      paymentStatus: PaymentStatus.unpaid,
      paymentMethod: PaymentMethod.eWallet,
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    ),
  ];
}

bool isAssetUrl(String url) => url.startsWith('asset:');

String assetPathOf(String url) => url.replaceFirst('asset:', '');
