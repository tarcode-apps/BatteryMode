#ifndef _Localization
	#define _Localization

;
; Localization
;

#include "..\Localization\English\EnglishInstaller.iss"
#include "..\Localization\Hungarian\HungarianInstaller.iss"
#include "..\Localization\Italian\ItalianInstaller.iss"
#include "..\Localization\Korean\KoreanInstaller.iss"
#include "..\Localization\Polish\PolishInstaller.iss"
#include "..\Localization\Russian\RussianInstaller.iss"
#include "..\Localization\Ukrainian\UkrainianInstaller.iss"
#include "..\Localization\BrazilianPortuguese\BrazilianPortugueseInstaller.iss"
#include "..\Localization\Japanese\JapaneseInstaller.iss"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"; LicenseFile: "..\LICENSE.txt"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"; LicenseFile: "..\LICENSE.txt"
Name: "hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"; LicenseFile: "..\LICENSE.txt"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"; LicenseFile: "..\LICENSE.txt"
Name: "korean"; MessagesFile: "..\Localization\Korean\Unofficial\Korean.isl"; LicenseFile: "..\LICENSE.txt"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"; LicenseFile: "..\LICENSE.txt"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"; LicenseFile: "..\Localization\Russian\License.txt"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"; LicenseFile: "..\Localization\Russian\License.txt"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"; LicenseFile: "..\LICENSE.txt"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"; LicenseFile: "..\LICENSE.txt"

#endif
