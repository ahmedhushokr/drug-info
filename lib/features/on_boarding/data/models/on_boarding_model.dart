class OnBoardingModel {
  final String image;
  final String titel;
  final String subtitel;

  OnBoardingModel({required this.image, required this.titel, required this.subtitel});

}
List<OnBoardingModel>  onBoardingData =[
  OnBoardingModel(image: "assets/svg_assets/happy.svg", titel: "Welcome to Druginfo!", subtitel:"Your smart assistant to instantly identify any medicine and learn its details." ),
  OnBoardingModel(image: "assets/svg_assets/mobile.svg", titel: "Snap a Photo", subtitel:"Just take a photo of any medicine box and our AI will provide accurate info." ),
  OnBoardingModel(image: "assets/svg_assets/medicine.svg", titel: "Stay Safe with Every Medicine", subtitel:"Know dosage, usage, and warnings easily, protecting your health effortlessly." ),

];
