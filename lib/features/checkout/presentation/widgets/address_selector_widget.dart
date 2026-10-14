import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/widgets/festive_auth_background.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/address.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_state.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/widgets/checkout_section_card.dart';

/// Widget for selecting delivery address
class AddressSelectorWidget extends StatefulWidget {
  const AddressSelectorWidget({super.key});

  @override
  State<AddressSelectorWidget> createState() => _AddressSelectorWidgetState();
}

class _AddressSelectorWidgetState extends State<AddressSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      buildWhen: (previous, current) =>
          current is CheckoutInitial ||
          current is AddressSelected ||
          current is CheckoutCalculated ||
          current is DeliveryOptionsLoading ||
          current is DeliveryOptionsLoaded,
      builder: (context, checkoutState) {
        Address? selectedAddress;

        if (checkoutState is AddressSelected) {
          selectedAddress = checkoutState.address;
        } else if (checkoutState is CheckoutCalculated) {
          selectedAddress =
              checkoutState.summary.selectedAddress ??
              context.read<CheckoutBloc>().selectedAddress;
        } else if (checkoutState is DeliveryOptionsLoading) {
          selectedAddress = checkoutState.selectedAddress;
        } else if (checkoutState is DeliveryOptionsLoaded) {
          selectedAddress = checkoutState.selectedAddress;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckoutSectionTitle(
              icon: Icons.location_on_rounded,
              title: AppLocalizations.of(context)!.deliveryAddress,
              trailing: selectedAddress != null
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showAddressSelector(context),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 10,
                            color: AppColors.primaryOrange,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            Container(
              decoration: checkoutCardDecoration(),
              child: selectedAddress == null
                  ? _buildNoAddressCard(context)
                  : _buildAddressCard(context, selectedAddress),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoAddressCard(BuildContext context) {
    return InkWell(
      onTap: () => _showAddressSelector(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primaryOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Select delivery address',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Address address) {
    final cityLine = [
      address.location.city,
      address.location.state,
    ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
    final postal = address.location.postalCode ?? '';
    final cityPostal = [cityLine, postal].where((e) => e.isNotEmpty).join(' - ');
    final street = [
      address.addressLine1,
      if (address.addressLine2 != null && address.addressLine2!.isNotEmpty)
        address.addressLine2!,
    ].join(', ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
      child: InkWell(
        onTap: () => _showAddressSelector(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFCF1E5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE3CB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Color(0xFF8A4B14),
                  size: 18,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDDCB8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        address.displayLabel,
                        style: const TextStyle(
                          color: Color(0xFFE07B12),
                          fontWeight: FontWeight.w500,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      street,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey900,
                        height: 1.2,
                      ),
                    ),
                    if (address.landmark != null &&
                        address.landmark!.isNotEmpty)
                      Text(
                        'Landmark: ${address.landmark}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey600,
                          height: 1.2,
                        ),
                      ),
                    Text(
                      cityPostal,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.grey600,
                        height: 1.25,
                      ),
                    ),
                    if (address.instructions != null &&
                        address.instructions!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 13,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                address.instructions!,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryOrange,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<CheckoutBloc>()),
                BlocProvider.value(value: context.read<AddressBloc>()),
              ],
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Address',
                          style: Theme.of(bottomSheetContext)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<AddressBloc, AddressState>(
                      builder: (context, state) {
                        if (state is AddressesLoaded) {
                          final addresses = state.addresses;

                          if (addresses.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 64,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('No addresses found'),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(bottomSheetContext);
                                      context.push(AppRoutes.addAddress);
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Address'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: addresses.length + 1,
                            itemBuilder: (context, index) {
                              if (index == addresses.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(bottomSheetContext);
                                      context.push(AppRoutes.addAddress);
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add New Address'),
                                  ),
                                );
                              }

                              final address = addresses[index];
                              return _AddressListItem(
                                address: address,
                                onSelect: () {
                                  context.read<CheckoutBloc>().add(
                                    SelectAddressEvent(address),
                                  );
                                  Navigator.pop(bottomSheetContext);
                                },
                              );
                            },
                          );
                        }

                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _AddressListItem extends StatelessWidget {
  final Address address;
  final VoidCallback onSelect;

  const _AddressListItem({required this.address, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return festiveCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  address.type.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.displayLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.shortAddress,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
