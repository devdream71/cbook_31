part of '../sales_view.dart';

class GiveInformation extends StatefulWidget {
  const GiveInformation({super.key});

  @override
  GiveInformationState createState() => GiveInformationState();
}

class GiveInformationState extends State<GiveInformation> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xffe7edf4),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.cancel,
                  size: 15,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xff38b0e3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                child: Text(
                  "Give Information",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            vPad10,
            InputField(
              controller: nameController,
              height: 30,
              hintText: "Customer Name",
              textStyle: const TextStyle(color: Colors.black, fontSize: 12),
            ),
            InputField(
              controller: phoneController,
              height: 30,
              hintText: "Mobile/Phone Number",
              textStyle: const TextStyle(color: Colors.black, fontSize: 12),
            ),
            InputField(
              controller: emailController,
              height: 30,
              hintText: "E-mail",
              textStyle: const TextStyle(color: Colors.black, fontSize: 12),
            ),
            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.primary, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: addressController,
                style: const TextStyle(color: Colors.black, fontSize: 12),
                cursorHeight: 12,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.only(bottom: 5, left: 5),
                  hintText: "Address",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            vPad5,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black.withOpacity(0.3)),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 4),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                hPad10,
                InkWell(
                  onTap: () {
                    setState(() {
                      controller.updatedCustomerInfomation(
                        nameFrom: nameController.value.text,
                        phoneFrom: phoneController.value.text,
                        emailFrom: emailController.value.text,
                        addressFrom: addressController.value.text,
                      );
                    });
                    debugPrint("dada");
                    Navigator.pop(context);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: colorScheme.primary),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 4),
                      child: Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
