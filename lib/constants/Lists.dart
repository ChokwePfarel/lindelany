final List<String> provinces = [
  'Eastern Cape',
  'Free State',
  'Gauteng',
  'KwaZulu-Natal',
  'Limpopo',
  'Mpumalanga',
  'Northern Cape',
  'North West',
  'Western Cape',
];

final List<String> gender = ['Male', 'Female'];

final List<String> genders = ['Males', 'Females', 'Mixed'];

final List<String> Typee = ['House', 'Back Room', 'Apartment'];
final List<String> Availability = [
  'single',
  'double',
  'single and double',
  'sharing only',
  'single,double & triple',
];

final List<String> southAfricanUniversities = [
  "University of Cape Town",
  "Stellenbosch University",
  "University of Pretoria",
  "University of the Witwatersrand",
  "University of KwaZulu-Natal",
  "University of the Western Cape",
  "Rhodes University",
  "University of South Africa",
  "Nelson Mandela University",
  "North-West University",
  "Sefako Makgatho Health Sciences University",
  "Sol Plaatje University",
  "University of Fort Hare",
  "University of Johannesburg",
  "University of Limpopo",
  "University of Mpumalanga",
  "University of the Free State",
  "University of Venda",
  "Tshwane University of Technology",
  "Durban University of Technology",
  "Central University of Technology",
  "Cape Peninsula University of Technology",
  "Mangosuthu University of Technology"
      "None",
];

final List<String> YearOfStudy = ['1st', '2nd', '3rd', '4th', 'Post'];

final List<String> Payment = ['NSFAS', 'Cash', 'Other'];

final List<String> userType = ['Student', 'LandLord', 'Transportation'];

final List<double> prices = [900, 500, 100, 1300, 600, 160];

final List<Map<String, String>> quickFilters = [
  {'label': 'All', 'query': ''},
  {'label': 'NSFAS', 'query': 'nsfas'},
  {'label': 'Females', 'query': 'females'},
  {'label': 'Mixed', 'query': 'mixed'}, // you could map this to "mixed"
  {'label': 'Males', 'query': 'males'},
  {'label': 'UP', 'query': 'up'},
  {'label': 'UWC', 'query': 'UWC'},
  {'label': 'UJ', 'query': 'uj'},
  {'label': 'WITS', 'query': 'wits'},
  {'label': 'UCT', 'query': 'uct'},
  {'label': 'TUT', 'query': 'tut'},
];

final List<Map<String, String>> quickFiltersNoNSFAS = [
  {'label': 'All', 'query': ''},
  {'label': 'UP', 'query': 'up'},
  {'label': 'UWC', 'query': 'UWC'},
  {'label': 'UJ', 'query': 'uj'},
  {'label': 'WITS', 'query': 'wits'},
  {'label': 'UCT', 'query': 'uct'},
  {'label': 'TUT', 'query': 'tut'},
];

// South African universities with their nicknames
final List<Map<String, String>> quickFiltersUni = [
  {'label': 'All', 'query': '', 'uni': ''},
  {
    'label': 'UCT',
    'query': 'University of Cape Town',
    'uni': 'University of Cape Town',
  },
  {
    'label': 'Wits',
    'query': 'University of the Witwatersrand',
    'uni': 'University of the Witwatersrand',
  },
  {
    'label': 'UP',
    'query': 'University of Pretoria',
    'uni': 'University of Pretoria',
  },
  {
    'label': 'Stellies',
    'query': 'Stellenbosch University',
    'uni': 'Stellenbosch University',
  },
  {
    'label': 'UKZN',
    'query': 'University of KwaZulu-Natal',
    'uni': 'University of KwaZulu-Natal',
  },
  {
    'label': 'UJ',
    'query': 'University of Johannesburg',
    'uni': 'University of Johannesburg',
  },
  {
    'label': 'NWU',
    'query': 'North-West University',
    'uni': 'North-West University',
  },
  {'label': 'Rhodes', 'query': 'Rhodes University', 'uni': 'Rhodes University'},
  {
    'label': 'Unisa',
    'query': 'University of South Africa',
    'uni': 'University of South Africa',
  },
];

/*return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: blue900,
        automaticallyImplyLeading: false,
        title: Center(
          child: lindelani(isLindeWhite: true, isLWhite: true),
        ),
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            icon: Icon(CupertinoIcons.list_bullet, size: 30, color: Colors.grey),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => allChats()));
            },
            icon: Icon(CupertinoIcons.bell_fill, color: Colors.grey),
          )
        ],
      ),
      drawer: const customDrawe(),*/
