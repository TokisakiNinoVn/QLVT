import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:txng/screens/farm_management/care_history/care_history_management_screen.dart';

import '../screens/farm_management/account/vungtrong_account_update_screen.dart';
import '../screens/farm_management/care_history/add_care_history_qr_screen.dart';
import '../screens/farm_management/care_history/add_care_history_screen.dart';
import '../screens/farm_management/care_history/care_history_create.dart';
import '../screens/farm_management/care_process/care_process_list_screen.dart';
import '../screens/farm_management/care_process/care_process_management_screen.dart';
import '../screens/farm_management/container/container_create_screen.dart';
import '../screens/farm_management/container/container_management_screen.dart';
import '../screens/farm_management/container/container_update_screen.dart';
import '../screens/farm_management/farm/farm_management_screen.dart';
import '../screens/farm_management/farm/farm_update_screen.dart';
import '../screens/farm_management/fertilizer_medicine/fertilizer_medicine_create_screen.dart';
import '../screens/farm_management/fertilizer_medicine/fertilizer_medicine_management_screen.dart';
import '../screens/farm_management/fertilizer_medicine/fertilizer_medicine_update_screen.dart';
import '../screens/farm_management/harvest_packaging/harvest_packaging_create_screen.dart';
import '../screens/farm_management/harvest_packaging/harvest_packaging_management_screen.dart';
import '../screens/farm_management/harvest_packaging/harvest_packaging_qr_screen.dart';
import '../screens/farm_management/harvest_packaging/harvest_packaging_qr_update_screen.dart';
import '../screens/farm_management/harvest_packaging/harvest_packaging_update_screen.dart';
import '../screens/farm_management/planting_area/planting_area_create_screen.dart';
import '../screens/farm_management/planting_area/planting_area_details_qr_screen.dart';
import '../screens/farm_management/planting_area/planting_area_details_update_screen.dart';
import '../screens/farm_management/planting_area/planting_area_management_screen.dart';
import '../screens/farm_management/planting_area/planting_area_qr_screen.dart';
import '../screens/farm_management/planting_area/planting_area_update_screen.dart';
import '../screens/farm_management/scan_qr_screen.dart';
import '../screens/farm_management/supplier/supplier_create_screen.dart';
import '../screens/farm_management/supplier/supplier_management_screen.dart';
import '../screens/farm_management/supplier/supplier_update_screen.dart';
import '../screens/farm_management/transport/transport_create_by_qr_screen.dart';
import '../screens/farm_management/transport/transport_create_screen.dart';
import '../screens/farm_management/transport/transport_management_screen.dart';
import '../screens/farm_management/transport/transport_update_screen.dart';
import '../screens/post_screen.dart';
import '../screens/production_facility/account/cssx_account_create_screen.dart';
import '../screens/production_facility/account/cssx_account_management_screen.dart';
import '../screens/production_facility/account/cssx_account_update_screen.dart';
import '../screens/production_facility/additive_products/additive_products_create_screen.dart';
import '../screens/production_facility/additive_products/additive_products_management_screen.dart';
import '../screens/production_facility/additive_products/additive_products_update_screen.dart';
import '../screens/production_facility/infor/infor_management_screen.dart';
import '../screens/production_facility/infor/infor_update_screen.dart';
import '../screens/production_facility/packaging/packaging_management_screen.dart';
import '../screens/production_facility/processing_history/processing_history_create_screen.dart';
import '../screens/production_facility/processing_history/processing_history_management_screen.dart';
import '../screens/production_facility/processing_history/processing_management_screen.dart';
import '../screens/production_facility/production_process/care_process_management_screen.dart';
import '../screens/farm_management/account/vungtrong_account_management_screen.dart';
import '../screens/farm_management/account/vungtrong_account_create_screen.dart';

import '../screens/production_facility/receive/reception_create_by_qr_screen.dart';
import '../screens/production_facility/receive/reception_management_screen.dart';
import '../screens/production_facility/receive/reception_qr_screen.dart';
import '../screens/production_facility/scan_qr_screen.dart';
import '../screens/production_facility/transport/transport_create_screen.dart';
import '../screens/production_facility/transport/transport_management_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../states/auth_state.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/option_login.dart';

final authState = AuthState();
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/list-post',
  refreshListenable: authState,
  // redirect: (context, state) {
  //   final isAtLogin = state.matchedLocation == '/option-login/login';
  //   final isAtOptionLogin = state.matchedLocation == '/option-login';
  //   final isSplash = state.matchedLocation == '/';
  //
  //   // Nếu chưa login mà không đang ở trang login => chuyển sang login
  //   if (!authState.isLoggedIn && !(isAtLogin || isAtOptionLogin || isSplash)) {
  //     return '/option-login';
  //   }
  //
  //   // Nếu đã login mà vẫn đang ở màn login => chuyển sang home
  //   if (authState.isLoggedIn && (isAtLogin || isAtOptionLogin || isSplash)) {
  //     return '/home';
  //   }
  //
  //   return null;
  // },
  redirect: (context, state) {
    final isAtLogin = state.matchedLocation == '/option-login/login';
    final isAtOptionLogin = state.matchedLocation == '/option-login';
    final isAtSplash = state.matchedLocation == '/';
    final isAtListPost = state.matchedLocation == '/list-post';

    // Nếu chưa login mà không ở list-post, option-login, login hoặc splash => về list-post
    // if (!authState.isLoggedIn &&
    //     !(isAtLogin || isAtOptionLogin || isAtSplash || isAtListPost)) {
    //   return '/list-post';
    // }

    // Nếu đã login mà vẫn ở list-post, option-login, login hoặc splash => sang home
    if (authState.isLoggedIn &&
        (isAtLogin || isAtOptionLogin || isAtSplash || isAtListPost)) {
      return '/home';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/list-post',
      builder: (context, state) => const ListPostScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/option-login',
      builder: (context, state) => const OptionLoginScreen(),
      routes: [
        GoRoute(
          path: 'login',
          builder:
              (context, state) => LoginScreen(
            roleType: state.pathParameters['roleType'] ?? 'nhancong',
          ),
        ),
      ],
    ),

    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'account-management',
          builder: (context, state) => const AccountManagementScreen(),
          routes: [
            GoRoute(
              path: 'account-create',
              builder: (context, state) => const AccountCreateScreen(),
            ),

            GoRoute(
              path: 'account-edit/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return AccountUpdateScreen(id: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'planting-area-management',
          builder: (context, state) => const PlantingAreaManagementScreen(),
          routes: [
            GoRoute(
              path: 'scan-qr-detailsvt',
              builder: (context, state) => const ScanQRDetailsVTScreen(),
            ),
            GoRoute(
              path: 'details-tv-qr/:code',
              // builder: (context, state) => const PlantingAreaQRDetailsVTScreen(),
              builder: (context, state) {
                final code = state.pathParameters['code'];
                return PlantingAreaQRDetailsVTScreen(code: code ?? '');
              },
            ),
            GoRoute(
              path: 'planting-area-create',
              builder: (context, state) => const PlantingAreaCreateScreen(),
            ),
            GoRoute(
              path: 'planting-area-details',
              builder: (context, state) {
                final plantingArea = state.extra as Map<String, dynamic>;
                return PlantingAreaDetailsScreen(plantingArea: plantingArea);
              },
            ),
            GoRoute(
              path: 'planting-area-edit',
              builder: (context, state) {
                final plantingArea = state.extra as Map<String, dynamic>;
                return PlantingAreaEditScreen(plantingArea: plantingArea);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'farm-management',
          builder: (context, state) => const FarmManagementScreen(),
          routes: [
            GoRoute(
              path: 'farm-update',
              builder: (context, state) => const FarmUpdateScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'harvest-packaging-management',
          builder: (context, state) => const HarvestPackagingManagementScreen(),
          routes: [
            GoRoute(
              path: 'harvest-packaging-qr',
              builder: (context, state) => const ScanQRHarvestPackagingScreen(),
            ),
            GoRoute(
              path: 'harvest-packaging-qr-update',
              builder: (context, state) => const ScanQRUpdateHarvestPackagingScreen(),
            ),
            GoRoute(
              path: 'create-harvest-packaging/:code',
              builder: (context, state) {
                final code = state.pathParameters['code'];
                return HarvestPackagingCreateScreen(code: code ?? '');
              },
            ),
            GoRoute(
              path: 'update-harvest-packaging/:code',
              builder: (context, state) {
                final code = state.pathParameters['code'];
                return HarvestPackagingUpdateScreen(code: code ?? '');
              },
            ),
          ],
        ),
        GoRoute(
            path: 'container-management',
            builder: (context, state) => const ContainerManagementScreen(),
            routes: [
              GoRoute(
                path: 'create-container',
                builder: (context, state) => const ContainerCreateScreen(),
              ),
              GoRoute(
                path: 'container-update/:id',
                builder: (context, state) {
                  final container = state.extra as Map<String, dynamic>;
                  return ContainerUpdateScreen(container: container);
                },
              ),
            ]
        ),

        GoRoute(
            path: 'supplier-management',
            builder: (context, state) => const SupplierManagementScreen(),
            routes: [
              GoRoute(
                path: 'create-supplier',
                builder: (context, state) => const SupplierCreateScreen(),
              ),
              GoRoute(
                path: 'edit-supplier/:id',
                builder: (context, state) {
                  final supplier = state.extra as Map<String, dynamic>;
                  final id = int.parse(state.pathParameters['id']!);
                  return SupplierUpdateScreen(supplier: supplier, id: id);
                },
              ),
            ]
        ),

        GoRoute(
          path: 'transport-management',
          builder: (context, state) => const TransportManagementScreen(),
          routes: [
            // GoRoute(
            //   path: 'transport-qr',
            //   builder: (context, state) => const ScanQRTransportScreen(),
            // ),
            GoRoute(
              path: 'create',
              builder: (context, state) => const TransportCreateScreen(),
            ),
            GoRoute(
              path: 'create-transport/:code',
              builder: (context, state) {
                final code = state.pathParameters['code'];
                return TransportCreateQRScreen(code: code ?? '');
              },
            ),
            GoRoute(
              path: 'update/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return TransportUpdateScreen(id: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'care-process-management',
          // builder: (context, state) => const CareProcessManagementScreen(),
          builder: (context, state) => const CareProcessListScreen(),
        ),
        GoRoute(
            path: 'care-history-management/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final plantingArea = state.extra as Map<String, dynamic>;
              return CareHistoryManagementScreen(
                id: id,
                plantingArea: plantingArea,
              );
            },
            routes: [

            ]
        ),
        GoRoute(
          path: 'create-care-history/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final plantingArea = state.extra as Map<String, dynamic>;
            return AddCareHistoryNormalScreen(
              id: id,
              plantingArea: plantingArea,
            );
          },
          // builder: (context, state) => const AddCareHistoryNormalScreen(),
        ),
        // GoRoute(
        //   path: 'create-care-history/:id',
        //   builder: (context, state) {
        //     final id = int.parse(state.pathParameters['id']!);
        //     return AddCareHistoryScreen(id: id);
        //   },
        //   // builder: (context, state) => const AddCareHistoryNormalScreen(),
        // ),
        GoRoute(
          path: 'create/care-history/:code',
          builder: (context, state) {
            final code = state.pathParameters['code'];
            return AddCareHistoryQRScreen(code: code ?? '');
          },
        ),

        GoRoute(
          path: 'fertilizer-medicine-management',
          builder:
              (context, state) => const FertilizerMedicineManagementScreen(),
          routes: [
            GoRoute(
              path: 'fertilizer-medicine-create',
              builder:
                  (context, state) => const FertilizerMedicineCreateScreen(),
            ),

            // update: param id
            GoRoute(
              path: 'fertilizer-medicine-update/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return FertilizerMedicineUpdateScreen(id: id);
              },
            ),
          ],
        ),

        // CSSX
        GoRoute(
          path: 'cssx-management',
          builder:
              (context, state) => const InforCSSXScreen(),
          routes: [
            GoRoute(
              path: 'cssx-update',
              builder:
                  (context, state) => const InforCSSXUpdateScreen(),
            ),
          ],
        ),
        GoRoute(
            path: 'processing-management',
            builder: (context, state) => const ProcessingManagementScreen(),
            routes: [
              GoRoute(
                path: 'processing-history/:code',
                builder: (context, state) {
                  final code = state.pathParameters['code'];
                  return ProcessingHistoryManagementScreen(code: code ?? '');
                },
              ),
              GoRoute(
                path: 'processing-history-create/:code',
                builder: (context, state) {
                  final code = state.pathParameters['code'];
                  return ProcessingHistoryAddScreen(code: code ?? '');
                },
              ),
            ]
        ),

        GoRoute(
          path: 'cssx-account-management',
          builder: (context, state) => const CSSXAccountManagementScreen(),
          routes: [
            GoRoute(
              path: 'cssx-account-create',
              builder: (context, state) => const CSSXAccountCreateScreen(),
            ),
            GoRoute(
              path: 'cssx-account-edit/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return CSSXAccountUpdateScreen(id: id);
              },
            ),
          ],
        ),

        GoRoute(
          path: 'production-process-management',
          builder: (context, state) => const ProductionProcessManagementScreen(),
        ),

        GoRoute(
          path: 'packaging-management',
          builder: (context, state) => const PackagingManagementScreen(),
        ),
        GoRoute(
            path: 'transport-cssx-management',
            builder: (context, state) => const TransportManagementCSSXScreen(),
            routes: [
              GoRoute(
                path: 'create-transport-cssx',
                builder: (context, state) => const TransportCreateCSSXScreenV2(),
              ),
            ]
        ),

        GoRoute(
          path: 'additive-products-management',
          builder: (context, state) => const AdditiveProductsManagementScreen(),
          routes: [
            GoRoute(
              path: 'additive-products-create',
              builder: (context, state) => const AdditiveProductsCreateScreen(),
            ),

            // update: param id
            GoRoute(
              path: 'additive-products-update/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return AdditiveProductsUpdateScreen(id: id);
              },
            ),
          ],
        ),

        GoRoute(
            path: 'reception-management',
            builder: (context, state) => const ReceptionManagementScreen(),
            routes: [
              GoRoute(
                path: 'scan-qr',
                builder: (context, state) => const ScanQRReceptionScreen(),
              ),
              GoRoute(
                path: 'create-reception/:code',
                builder: (context, state) {
                  final code = state.pathParameters['code'];
                  return ReceptionCreateQRScreen(code: code ?? '');
                },
              ),
            ]
        ),

        GoRoute(
          path: 'scan-qr',
          builder: (context, state) => const ScanQRVTScreen(),
        ),
        GoRoute(
          path: 'scan-qr-cssx',
          builder: (context, state) => const ScanQRCSSXScreen(),
        ),
      ],
    ),

    GoRoute(
      path: '/add-care-history',
      builder: (context, state) => const AddCareHistoryScreen(),
    ),
  ],
);
