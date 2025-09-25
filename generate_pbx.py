import json
from pathlib import Path

build_files = [
    ("0B401BE29AC547BE97B2BBC9B6627BB6", "fares_config.json in Resources", "DF962B16DC574B18864520BB6C8F7B71", "fares_config.json"),
    ("0F94DB5B0FFD414B94AD397F66E56566", "SharedComponents.swift in Sources", "C9BE5809471D4ACAA1CA31ABC1A828CF", "SharedComponents.swift"),
    ("1929634F6BC04705965471981ED5791D", "PaymentsFeature.swift in Sources", "5E07DDF5C5684C05B2C6180FD987004E", "PaymentsFeature.swift"),
    ("1B6300A431CB49C9B9C9AE33DFCDB2AA", "stations.json in Resources", "91072CA6FE4546D1B11A026EA69CFD82", "stations.json"),
    ("2440393F08554AB9A76B5F8E2510A5BA", "PoiService.swift in Sources", "36EF10CCC0CE4398B9EB7064F895E64A", "PoiService.swift"),
    ("45D007163FE0497FAB2C8BA754485F1C", "DiscoverFeature.swift in Sources", "C726873733654A5AAAF6C20DC82E409C", "DiscoverFeature.swift"),
    ("4B108C3A7DAF479093E851E79F1FA206", "JourneyTHApp.swift in Sources", "B1FAABA271344FB88FE4C5787F826043", "JourneyTHApp.swift"),
    ("5801E565694C43B4AEBD4E24883BDE5C", "Assets.xcassets in Resources", "9BDE6A65E50B42DAA7F0FCACE4E92175", "Assets.xcassets"),
    ("6EE7497C8BA94366BF71BADBAAB3B6D5", "EsimPlan.swift in Sources", "F458FA79BA7C4F54BE5D37BA6F10D472", "EsimPlan.swift"),
    ("7488EBB0C5D04819A202E98D74273823", "TransportService.swift in Sources", "6CD204A9303E4AEA898B8870E6A3EA6A", "TransportService.swift"),
    ("7A7795B785544A33BD9E6A684293CD1C", "TransportRoute.swift in Sources", "F5A56803A65249C3A5630D2CC1411923", "TransportRoute.swift"),
    ("8F7AD27BF2F4478791EAD2E08A94FB06", "ItineraryFeature.swift in Sources", "A56820073EF24CBD8E17952FC55E21CF", "ItineraryFeature.swift"),
    ("9B334F16F8394AE1A85A13EB87239E3D", "EsimFeature.swift in Sources", "E606100D0DF34F5294D288409D91ED2A", "EsimFeature.swift"),
    ("9DF485B541FB495BA3AB03F3FA70DAFE", "pois.json in Resources", "91C05ECBF1644A69BB0977C6EC8BB656", "pois.json"),
    ("AA8829520D574593B2BE06F9A2D5252F", "Persistence.swift in Sources", "9A986428DD23477AAC6355BDD9A2D5C9", "Persistence.swift"),
    ("B3E3EF69B8714C8EB3E12813A98B3C34", "OrderModel.swift in Sources", "5D77BEDAEFF74199B55147D585E814C2", "OrderModel.swift"),
    ("BA964D783A6C4FC49CB22A946A016EB8", "AccountFeature.swift in Sources", "BD8927F09F3C46BFA3E1AB54A2573C45", "AccountFeature.swift"),
    ("CA08AEE838414AAD8190629D7522D4D4", "PlanLoader.swift in Sources", "FC46CE28CE744A56B56D012F8855A4DA", "PlanLoader.swift"),
    ("D079E00F5BFF442E8B3E058370F57DBD", "OrderService.swift in Sources", "16245B883427418D8E6EB5E715C2608D", "OrderService.swift"),
    ("E12A73A08ECD47DF8681D9109908DC95", "LocalDataLoader.swift in Sources", "F5E25C83484E4C5D85F2759A83C8B002", "LocalDataLoader.swift"),
    ("EF419844F2084FC0904F53003C96382B", "AppSettings.swift in Sources", "05C0BD92CD2642EFB42B64D0B096EDEE", "AppSettings.swift"),
    ("F870F5C828DA4AE3A8AB3B43507FA391", "TransportFeature.swift in Sources", "76BAEE7AA8CD42888B6B8297F411B8A2", "TransportFeature.swift"),
    ("FF192049B2AC4E7BB21949AF6945662E", "JourneyTH.xcdatamodeld in Resources", "6ADEDD1F99744762AAA2BC49BD418770", "JourneyTH.xcdatamodeld"),
    ("A94D8F43BA194F0D94B5602F00D5F01E", "Localizable.strings in Resources", "814928D0D8DD4EE3B92B8702FFA15231", "Localizable.strings"),
]

test_build_files = [
    ("A623F952FAFE4F3CB6B23909FC329D80", "TransportViewModelTests.swift in Sources", "AD9639B5FA9442EF8C93471C274351F2", "TransportViewModelTests.swift"),
    ("6408A3AF5B424F7B8302A613E58108AF", "PoiViewModelTests.swift in Sources", "AFF06062C05041329C88A5C549D9C188", "PoiViewModelTests.swift"),
    ("3ABCFA3A7D0D4E4EAE2866772E2F8201", "ItineraryRepositoryTests.swift in Sources", "F66E467385C24E37AC1397AF80F041C9", "ItineraryRepositoryTests.swift"),
    ("05833FE86B234D20AAE4651C70D84BE2", "OrderServiceTests.swift in Sources", "52A4D820998E4546898C8695748D6604", "OrderServiceTests.swift"),
]

resource_build_files = [
    "0B401BE29AC547BE97B2BBC9B6627BB6",
    "1B6300A431CB49C9B9C9AE33DFCDB2AA",
    "9DF485B541FB495BA3AB03F3FA70DAFE",
    "5801E565694C43B4AEBD4E24883BDE5C",
    "FF192049B2AC4E7BB21949AF6945662E",
    "A94D8F43BA194F0D94B5602F00D5F01E",
]

package_build_files = [
    ("5F0D21A3E1F8402AA5F34012", "OrderedCollections in Frameworks", "B1E1F2C4A28F47FF9CB7AA61"),
]

package_product_dependencies = [
    ("B1E1F2C4A28F47FF9CB7AA61", "OrderedCollections", "D5A7F3B9E41F4E5F9A2B1C7D"),
]

package_references = [
    ("D5A7F3B9E41F4E5F9A2B1C7D", "swift-collections", "https://github.com/apple/swift-collections", "1.0.4", "937e904258d22af6e447a0b72c0bc67583ef64a2"),
]

app_framework_files = [pkg[0] for pkg in package_build_files]
test_framework_files = []

package_reference_map = {
    rid: (name, url, min_version, revision)
    for rid, name, url, min_version, revision in package_references
}

app_sources = [
    "4B108C3A7DAF479093E851E79F1FA206",
    "0F94DB5B0FFD414B94AD397F66E56566",
    "1929634F6BC04705965471981ED5791D",
    "2440393F08554AB9A76B5F8E2510A5BA",
    "45D007163FE0497FAB2C8BA754485F1C",
    "6EE7497C8BA94366BF71BADBAAB3B6D5",
    "7488EBB0C5D04819A202E98D74273823",
    "7A7795B785544A33BD9E6A684293CD1C",
    "8F7AD27BF2F4478791EAD2E08A94FB06",
    "9B334F16F8394AE1A85A13EB87239E3D",
    "AA8829520D574593B2BE06F9A2D5252F",
    "B3E3EF69B8714C8EB3E12813A98B3C34",
    "BA964D783A6C4FC49CB22A946A016EB8",
    "CA08AEE838414AAD8190629D7522D4D4",
    "D079E00F5BFF442E8B3E058370F57DBD",
    "E12A73A08ECD47DF8681D9109908DC95",
    "EF419844F2084FC0904F53003C96382B",
    "F870F5C828DA4AE3A8AB3B43507FA391",
]

app_resources_phase = "9B844106FEE54C71BEEC7E23B667677E"
app_sources_phase = "FCDB113566C3466AA3087BBD7DD45D58"
app_frameworks_phase = "1826E90C4AC3439983EB4553E23F8ED2"

test_sources_phase = "0BA224D65BD8452A922D1A28C536C5DF"
test_resources_phase = "4B95F9C09D234038868F3462F44F64AB"
test_frameworks_phase = "C68CE1376718499FB02CD49079B41642"

build_file_map = {
    bid: (comment, file_ref, file_comment)
    for bid, comment, file_ref, file_comment in build_files + test_build_files
}
package_build_file_map = {
    bid: (comment, product_ref)
    for bid, comment, product_ref in package_build_files
}
for bid, (comment, _) in package_build_file_map.items():
    build_file_map[bid] = (comment, None, None)

project_debug_settings = [
    ("ALWAYS_SEARCH_USER_PATHS", "NO"),
    ("CLANG_WARN_DOCUMENTATION_COMMENTS", "YES"),
    ("CLANG_WARN_UNGUARDED_AVAILABILITY", "YES_AGGRESSIVE"),
    ("DEBUG_INFORMATION_FORMAT", "dwarf"),
    ("ENABLE_TESTABILITY", "YES"),
    ("GCC_C_LANGUAGE_STANDARD", "gnu17"),
    ("GCC_NO_COMMON_BLOCKS", "YES"),
    ("GCC_WARN_ABOUT_RETURN_TYPE", "YES_ERROR"),
    ("GCC_WARN_UNDECLARED_SELECTOR", "YES"),
    ("GCC_WARN_UNUSED_FUNCTION", "YES"),
    ("GCC_WARN_UNUSED_VARIABLE", "YES"),
    ("IPHONEOS_DEPLOYMENT_TARGET", "17.0"),
    ("MTL_ENABLE_DEBUG_INFO", "INCLUDE_SOURCE"),
    ("ONLY_ACTIVE_ARCH", "YES"),
    ("SWIFT_ACTIVE_COMPILATION_CONDITIONS", "DEBUG"),
    ("SWIFT_OPTIMIZATION_LEVEL", "\"-Onone\""),
    ("SWIFT_VERSION", "5.9"),
]

project_release_settings = [
    ("ALWAYS_SEARCH_USER_PATHS", "NO"),
    ("CLANG_WARN_DOCUMENTATION_COMMENTS", "YES"),
    ("CLANG_WARN_UNGUARDED_AVAILABILITY", "YES_AGGRESSIVE"),
    ("GCC_C_LANGUAGE_STANDARD", "gnu17"),
    ("GCC_NO_COMMON_BLOCKS", "YES"),
    ("GCC_WARN_ABOUT_RETURN_TYPE", "YES_ERROR"),
    ("GCC_WARN_UNDECLARED_SELECTOR", "YES"),
    ("GCC_WARN_UNUSED_FUNCTION", "YES"),
    ("GCC_WARN_UNUSED_VARIABLE", "YES"),
    ("IPHONEOS_DEPLOYMENT_TARGET", "17.0"),
    ("MTL_ENABLE_DEBUG_INFO", "NO"),
    ("SWIFT_COMPILATION_MODE", "wholemodule"),
    ("SWIFT_OPTIMIZATION_LEVEL", "\"-O\""),
    ("SWIFT_VERSION", "5.9"),
    ("VALIDATE_PRODUCT", "YES"),
]

app_debug_settings = [
    ("ASSETCATALOG_COMPILER_APPICON_NAME", "AppIcon"),
    ("CODE_SIGN_STYLE", "Automatic"),
    ("CURRENT_PROJECT_VERSION", "1"),
    ("GENERATE_INFOPLIST_FILE", "YES"),
    ("INFOPLIST_KEY_UIApplicationSceneManifest_Generation", "YES"),
    ("INFOPLIST_KEY_UILaunchScreen_Generation", "YES"),
    ("IPHONEOS_DEPLOYMENT_TARGET", "17.0"),
    ("MARKETING_VERSION", "1.0"),
    ("PRODUCT_BUNDLE_IDENTIFIER", "com.example.JourneyTH"),
    ("PRODUCT_NAME", "\"$(TARGET_NAME)\""),
    ("SWIFT_EMIT_LOC_STRINGS", "YES"),
    ("SWIFT_VERSION", "5.9"),
    ("TARGETED_DEVICE_FAMILY", "1"),
]

app_release_settings = [
    ("ASSETCATALOG_COMPILER_APPICON_NAME", "AppIcon"),
    ("CODE_SIGN_STYLE", "Automatic"),
    ("CURRENT_PROJECT_VERSION", "1"),
    ("GENERATE_INFOPLIST_FILE", "YES"),
    ("INFOPLIST_KEY_UIApplicationSceneManifest_Generation", "YES"),
    ("INFOPLIST_KEY_UILaunchScreen_Generation", "YES"),
    ("IPHONEOS_DEPLOYMENT_TARGET", "17.0"),
    ("MARKETING_VERSION", "1.0"),
    ("PRODUCT_BUNDLE_IDENTIFIER", "com.example.JourneyTH"),
    ("PRODUCT_NAME", "\"$(TARGET_NAME)\""),
    ("SWIFT_EMIT_LOC_STRINGS", "YES"),
    ("SWIFT_OPTIMIZATION_LEVEL", "\"-Owholemodule\""),
    ("SWIFT_VERSION", "5.9"),
    ("TARGETED_DEVICE_FAMILY", "1"),
]

test_debug_settings = [
    ("CODE_SIGN_STYLE", "Automatic"),
    ("GENERATE_INFOPLIST_FILE", "YES"),
    ("IPHONEOS_DEPLOYMENT_TARGET", "17.0"),
    ("PRODUCT_BUNDLE_IDENTIFIER", "com.example.JourneyTHTests"),
    ("PRODUCT_NAME", "\"$(TARGET_NAME)\""),
    ("SWIFT_VERSION", "5.9"),
    ("TARGETED_DEVICE_FAMILY", "1"),
]

test_release_settings = list(test_debug_settings)


def normalize_id(identifier):
    if not isinstance(identifier, str):
        return identifier
    if len(identifier) == 32 and all(c in "0123456789ABCDEF" for c in identifier):
        return identifier[:24]
    return identifier


def add(lines, text="", indent=0):
    if text:
        lines.append("\t" * indent + text)
    else:
        lines.append("")


file_refs = {
    "B1FAABA271344FB88FE4C5787F826043": ("JourneyTHApp.swift", "sourcecode.swift", "JourneyTHApp.swift", "<group>", None),
    "05C0BD92CD2642EFB42B64D0B096EDEE": ("AppSettings.swift", "sourcecode.swift", "AppSettings.swift", "<group>", None),
    "C9BE5809471D4ACAA1CA31ABC1A828CF": ("SharedComponents.swift", "sourcecode.swift", "SharedComponents.swift", "<group>", None),
    "76BAEE7AA8CD42888B6B8297F411B8A2": ("TransportFeature.swift", "sourcecode.swift", "TransportFeature.swift", "<group>", None),
    "C726873733654A5AAAF6C20DC82E409C": ("DiscoverFeature.swift", "sourcecode.swift", "DiscoverFeature.swift", "<group>", None),
    "A56820073EF24CBD8E17952FC55E21CF": ("ItineraryFeature.swift", "sourcecode.swift", "ItineraryFeature.swift", "<group>", None),
    "E606100D0DF34F5294D288409D91ED2A": ("EsimFeature.swift", "sourcecode.swift", "EsimFeature.swift", "<group>", None),
    "5E07DDF5C5684C05B2C6180FD987004E": ("PaymentsFeature.swift", "sourcecode.swift", "PaymentsFeature.swift", "<group>", None),
    "BD8927F09F3C46BFA3E1AB54A2573C45": ("AccountFeature.swift", "sourcecode.swift", "AccountFeature.swift", "<group>", None),
    "F5A56803A65249C3A5630D2CC1411923": ("TransportRoute.swift", "sourcecode.swift", "TransportRoute.swift", "<group>", None),
    "491BAA9C25A8486C8B4A912173BDFF9C": ("Poi.swift", "sourcecode.swift", "Poi.swift", "<group>", None),
    "F458FA79BA7C4F54BE5D37BA6F10D472": ("EsimPlan.swift", "sourcecode.swift", "EsimPlan.swift", "<group>", None),
    "5D77BEDAEFF74199B55147D585E814C2": ("OrderModel.swift", "sourcecode.swift", "OrderModel.swift", "<group>", None),
    "F5E25C83484E4C5D85F2759A83C8B002": ("LocalDataLoader.swift", "sourcecode.swift", "LocalDataLoader.swift", "<group>", None),
    "6CD204A9303E4AEA898B8870E6A3EA6A": ("TransportService.swift", "sourcecode.swift", "TransportService.swift", "<group>", None),
    "36EF10CCC0CE4398B9EB7064F895E64A": ("PoiService.swift", "sourcecode.swift", "PoiService.swift", "<group>", None),
    "16245B883427418D8E6EB5E715C2608D": ("OrderService.swift", "sourcecode.swift", "OrderService.swift", "<group>", None),
    "9A986428DD23477AAC6355BDD9A2D5C9": ("Persistence.swift", "sourcecode.swift", "Persistence.swift", "<group>", None),
    "FC46CE28CE744A56B56D012F8855A4DA": ("PlanLoader.swift", "sourcecode.swift", "PlanLoader.swift", "<group>", None),
    "DF962B16DC574B18864520BB6C8F7B71": ("fares_config.json", "text.json", "fares_config.json", "<group>", None),
    "91C05ECBF1644A69BB0977C6EC8BB656": ("pois.json", "text.json", "pois.json", "<group>", None),
    "91072CA6FE4546D1B11A026EA69CFD82": ("stations.json", "text.json", "stations.json", "<group>", None),
    "9BDE6A65E50B42DAA7F0FCACE4E92175": ("Assets.xcassets", "folder.assetcatalog", "Assets.xcassets", "<group>", None),
    "6ADEDD1F99744762AAA2BC49BD418770": ("JourneyTH.xcdatamodeld", "wrapper.xcdatamodeld", "JourneyTH.xcdatamodeld", "<group>", None),
    "AD9639B5FA9442EF8C93471C274351F2": ("TransportViewModelTests.swift", "sourcecode.swift", "TransportViewModelTests.swift", "<group>", None),
    "AFF06062C05041329C88A5C549D9C188": ("PoiViewModelTests.swift", "sourcecode.swift", "PoiViewModelTests.swift", "<group>", None),
    "F66E467385C24E37AC1397AF80F041C9": ("ItineraryRepositoryTests.swift", "sourcecode.swift", "ItineraryRepositoryTests.swift", "<group>", None),
    "52A4D820998E4546898C8695748D6604": ("OrderServiceTests.swift", "sourcecode.swift", "OrderServiceTests.swift", "<group>", None),
    "2C5C847824774C5C86885E19AD6D7FAB": ("en", "text.plist.strings", "en.lproj/Localizable.strings", "<group>", "en"),
    "B44213AB2E084C7DA4A40A73796DD149": ("th", "text.plist.strings", "th.lproj/Localizable.strings", "<group>", "th"),
    "EDEFAF81E471449BA01CDB83D7DE73CF": ("JourneyTH.app", "wrapper.application", "JourneyTH.app", "BUILT_PRODUCTS_DIR", None),
    "C460CDD0F8484BC9B1898F4E32831B7B": ("JourneyTHTests.xctest", "wrapper.cfbundle", "JourneyTHTests.xctest", "BUILT_PRODUCTS_DIR", None),
}

variant_group = ("814928D0D8DD4EE3B92B8702FFA15231", "Localizable.strings", ["2C5C847824774C5C86885E19AD6D7FAB", "B44213AB2E084C7DA4A40A73796DD149"])

# PBXGroup definitions
groups = {
    "C82283E8BE864528A747D2F7A83317C0": ("", None, ["0DB5D6543BA0449EB3D7BCAEA31D226B", "15705C559F48472EAD723162B86AC98F", "462D4819A0CB4833AE150112EF7A29AB", "49EE75DF10BF469FB5DB19617997EA50"]),
    "0DB5D6543BA0449EB3D7BCAEA31D226B": ("JourneyTH", "JourneyTH", ["B1FAABA271344FB88FE4C5787F826043", "992568F9E3514B579BFB32E8DC41C67B", "64E0E4D8BF444CE7B22882C10CCBCC8E", "4B25A2265D8A459BAA10F887997A1334", "F733CF0E84FC4FCA86536ADB9C26B44D", "47E0D37270D244A89682C822C4E78EF9"]),
    "992568F9E3514B579BFB32E8DC41C67B": ("Features", "Features", ["37354241611F45799E3D32649E675F99", "86D459A535584AEA9C453098A55F57AB", "D4400F01B8A84115B9250B4CEEE7D245", "C4F26EBE073C4274BB587AF2E33B10FD", "69D8BC34DE8E4CBDBD532E2AE86D0597", "3DD0AAD2ED104C8081D3774D9D1F9C22", "DC925BCF35A948FCA68A9EFA95DF95AC"]),
    "37354241611F45799E3D32649E675F99": ("Shared", "Shared", ["05C0BD92CD2642EFB42B64D0B096EDEE", "C9BE5809471D4ACAA1CA31ABC1A828CF"]),
    "86D459A535584AEA9C453098A55F57AB": ("Transport", "Transport", ["76BAEE7AA8CD42888B6B8297F411B8A2"]),
    "D4400F01B8A84115B9250B4CEEE7D245": ("Discover", "Discover", ["C726873733654A5AAAF6C20DC82E409C"]),
    "C4F26EBE073C4274BB587AF2E33B10FD": ("Itinerary", "Itinerary", ["A56820073EF24CBD8E17952FC55E21CF"]),
    "69D8BC34DE8E4CBDBD532E2AE86D0597": ("Esim", "Esim", ["E606100D0DF34F5294D288409D91ED2A"]),
    "3DD0AAD2ED104C8081D3774D9D1F9C22": ("Payments", "Payments", ["5E07DDF5C5684C05B2C6180FD987004E"]),
    "DC925BCF35A948FCA68A9EFA95DF95AC": ("Account", "Account", ["BD8927F09F3C46BFA3E1AB54A2573C45"]),
    "64E0E4D8BF444CE7B22882C10CCBCC8E": ("Models", "Models", ["F5A56803A65249C3A5630D2CC1411923", "491BAA9C25A8486C8B4A912173BDFF9C", "F458FA79BA7C4F54BE5D37BA6F10D472", "5D77BEDAEFF74199B55147D585E814C2"]),
    "4B25A2265D8A459BAA10F887997A1334": ("Services", "Services", ["F5E25C83484E4C5D85F2759A83C8B002", "6CD204A9303E4AEA898B8870E6A3EA6A", "36EF10CCC0CE4398B9EB7064F895E64A", "16245B883427418D8E6EB5E715C2608D", "9A986428DD23477AAC6355BDD9A2D5C9", "FC46CE28CE744A56B56D012F8855A4DA"]),
    "F733CF0E84FC4FCA86536ADB9C26B44D": ("Resources", "Resources", ["AA1467DA18A6437DB8006AD167FD3E01", "3E73571D642847898629AB66C51C48A9", "9BDE6A65E50B42DAA7F0FCACE4E92175"]),
    "AA1467DA18A6437DB8006AD167FD3E01": ("Data", "Data", ["DF962B16DC574B18864520BB6C8F7B71", "91C05ECBF1644A69BB0977C6EC8BB656", "91072CA6FE4546D1B11A026EA69CFD82"]),
    "3E73571D642847898629AB66C51C48A9": ("Localizations", "Localizations", ["814928D0D8DD4EE3B92B8702FFA15231"]),
    "47E0D37270D244A89682C822C4E78EF9": ("CoreData", "CoreData", ["6ADEDD1F99744762AAA2BC49BD418770"]),
    "15705C559F48472EAD723162B86AC98F": ("Tests", "Tests", ["AD9639B5FA9442EF8C93471C274351F2", "AFF06062C05041329C88A5C549D9C188", "F66E467385C24E37AC1397AF80F041C9", "52A4D820998E4546898C8695748D6604"]),
    "462D4819A0CB4833AE150112EF7A29AB": ("Products", None, ["EDEFAF81E471449BA01CDB83D7DE73CF", "C460CDD0F8484BC9B1898F4E32831B7B"]),
    "49EE75DF10BF469FB5DB19617997EA50": ("Frameworks", None, []),
}

variant_group_id, variant_name, variant_children = variant_group

app_target = "39B43CB0CC254B7EB0DC56A68B1B3DA8"
test_target = "7D5E5DEE4D09405DA95019C510A45B34"
project_id = "37088684A8C14E49AF159A3CB05ADBDB"

app_product = "EDEFAF81E471449BA01CDB83D7DE73CF"
test_product = "C460CDD0F8484BC9B1898F4E32831B7B"

app_resources_phase = normalize_id(app_resources_phase)
app_sources_phase = normalize_id(app_sources_phase)
app_frameworks_phase = normalize_id(app_frameworks_phase)

test_sources_phase = normalize_id(test_sources_phase)
test_resources_phase = normalize_id(test_resources_phase)
test_frameworks_phase = normalize_id(test_frameworks_phase)

app_target = normalize_id(app_target)
test_target = normalize_id(test_target)
project_id = normalize_id(project_id)
app_product = normalize_id(app_product)
test_product = normalize_id(test_product)

project_build_config_list = normalize_id("48FE4AC96B74498194B0D75F4A2105CF")
app_build_config_list = normalize_id("A94D40C2F8FC42629F640CD095B796A5")
test_build_config_list = normalize_id("BA4170AD04464A4E9E8BC6AA57094B2D")

project_debug_config = normalize_id("745C0DB40D0B43FC9FEE81AF97CC6BBC")
project_release_config = normalize_id("3ADF79AEEBEA4A0ABD6660461B4FFA29")
app_debug_config = normalize_id("BD36F355AE5D404DB99FE11F5B38BE68")
app_release_config = normalize_id("2A02174B22884437BA2130EFCF1DAA63")
test_debug_config = normalize_id("0B53C482991D4CB3A5D001140109523E")
test_release_config = normalize_id("77E183D9A2774B0D8B985CED6707BC7F")

container_proxy_id = normalize_id("0277F47312AB481FBD115BB4A9F61D96")
target_dependency_id = normalize_id("4359A57CB6D84B00A3060827FA3B678F")

main_group_id = normalize_id("C82283E8BE864528A747D2F7A83317C0")
product_ref_group_id = normalize_id("462D4819A0CB4833AE150112EF7A29AB")

lines = []
add(lines, "// !$*UTF8*$!")
add(lines, "{")
add(lines, "archiveVersion = 1;", 1)
add(lines, "classes = {", 1)
add(lines, "};", 1)
add(lines, "objectVersion = 56;", 1)
add(lines, "objects = {", 1)
add(lines)

add(lines, "/* Begin PBXBuildFile section */")
for bid, comment, file_ref, file_comment in build_files + test_build_files:
    add(
        lines,
        f"{normalize_id(bid)} /* {comment} */ = {{isa = PBXBuildFile; fileRef = {normalize_id(file_ref)} /* {file_comment} */; }};",
        2,
    )
for bid, comment, product_ref in package_build_files:
    add(
        lines,
        f"{normalize_id(bid)} /* {comment} */ = {{isa = PBXBuildFile; productRef = {normalize_id(product_ref)} /* {comment.split(' in ')[0]} */; }};",
        2,
    )
add(lines, "/* End PBXBuildFile section */")
add(lines)

add(lines, "/* Begin PBXContainerItemProxy section */")
add(lines, f"{container_proxy_id} /* PBXContainerItemProxy */ = {{", 2)
add(lines, "isa = PBXContainerItemProxy;", 3)
add(lines, f"containerPortal = {project_id} /* Project object */;", 3)
add(lines, "proxyType = 1;", 3)
add(lines, f"remoteGlobalIDString = {app_target};", 3)
add(lines, "remoteInfo = JourneyTH;", 3)
add(lines, "};", 2)
add(lines, "/* End PBXContainerItemProxy section */")
add(lines)

add(lines, "/* Begin PBXFileReference section */")
for fid, (comment, ftype, path, source_tree, name) in file_refs.items():
    normalized_fid = normalize_id(fid)
    attrs = ["isa = PBXFileReference", f"lastKnownFileType = {ftype}"]
    if name is not None:
        attrs.append(f"name = {name}")
    attrs.append(f"path = {path}")
    tree_value = f'"{source_tree}"' if source_tree == "<group>" else source_tree
    attrs.append(f"sourceTree = {tree_value}")
    add(lines, f"{normalized_fid} /* {comment} */ = {{{'; '.join(attrs)}; }};", 2)
add(lines, "/* End PBXFileReference section */")
add(lines)

add(lines, "/* Begin PBXFrameworksBuildPhase section */")
for phase, file_ids in ((app_frameworks_phase, app_framework_files), (test_frameworks_phase, test_framework_files)):
    add(lines, f"{phase} /* Frameworks */ = {{", 2)
    add(lines, "isa = PBXFrameworksBuildPhase;", 3)
    add(lines, "buildActionMask = 2147483647;", 3)
    add(lines, "files = (", 3)
    for fid in file_ids:
        comment = build_file_map[fid][0]
        add(lines, f"{normalize_id(fid)} /* {comment} */,", 4)
    add(lines, ");", 3)
    add(lines, "runOnlyForDeploymentPostprocessing = 0;", 3)
    add(lines, "};", 2)
add(lines, "/* End PBXFrameworksBuildPhase section */")
add(lines)

add(lines, "/* Begin PBXGroup section */")
for gid, (name, path, children) in groups.items():
    normalized_gid = normalize_id(gid)
    add(lines, f"{normalized_gid} = {{", 2)
    add(lines, "isa = PBXGroup;", 3)
    add(lines, "children = (", 3)
    for child in children:
        if child in file_refs:
            comment = file_refs[child][0]
        elif child == variant_group_id:
            comment = variant_name
        else:
            comment = groups[child][0]
        if not comment:
            comment = child
        add(lines, f"{normalize_id(child)} /* {comment} */,", 4)
    add(lines, ");", 3)
    if name:
        add(lines, f"name = {name};", 3)
    if path:
        add(lines, f"path = {path};", 3)
    add(lines, 'sourceTree = "<group>";', 3)
    add(lines, "};", 2)
add(lines, "/* End PBXGroup section */")
add(lines)

add(lines, "/* Begin PBXNativeTarget section */")
add(lines, f"{app_target} /* JourneyTH */ = {{", 2)
add(lines, "isa = PBXNativeTarget;", 3)
add(lines, f"buildConfigurationList = {app_build_config_list} /* Build configuration list for PBXNativeTarget \"JourneyTH\" */;", 3)
add(lines, "buildPhases = (", 3)
add(lines, f"{app_frameworks_phase} /* Frameworks */,", 4)
add(lines, f"{app_sources_phase} /* Sources */,", 4)
add(lines, f"{app_resources_phase} /* Resources */,", 4)
add(lines, ");", 3)
add(lines, "buildRules = (", 3)
add(lines, ");", 3)
add(lines, "dependencies = (", 3)
add(lines, ");", 3)
if package_product_dependencies:
    add(lines, "packageProductDependencies = (", 3)
    for pid, name, _ in package_product_dependencies:
        add(lines, f"{normalize_id(pid)} /* {name} */,", 4)
    add(lines, ");", 3)
add(lines, "name = JourneyTH;", 3)
add(lines, "productName = JourneyTH;", 3)
add(lines, f"productReference = {app_product} /* JourneyTH.app */;", 3)
add(lines, 'productType = "com.apple.product-type.application";', 3)
add(lines, "};", 2)
add(lines, f"{test_target} /* JourneyTHTests */ = {{", 2)
add(lines, "isa = PBXNativeTarget;", 3)
add(lines, f"buildConfigurationList = {test_build_config_list} /* Build configuration list for PBXNativeTarget \"JourneyTHTests\" */;", 3)
add(lines, "buildPhases = (", 3)
add(lines, f"{test_frameworks_phase} /* Frameworks */,", 4)
add(lines, f"{test_sources_phase} /* Sources */,", 4)
add(lines, f"{test_resources_phase} /* Resources */,", 4)
add(lines, ");", 3)
add(lines, "buildRules = (", 3)
add(lines, ");", 3)
add(lines, "dependencies = (", 3)
add(lines, f"{target_dependency_id} /* PBXTargetDependency */,", 4)
add(lines, ");", 3)
add(lines, "name = JourneyTHTests;", 3)
add(lines, "productName = JourneyTHTests;", 3)
add(lines, f"productReference = {test_product} /* JourneyTHTests.xctest */;", 3)
add(lines, 'productType = "com.apple.product-type.bundle.unit-test";', 3)
add(lines, "};", 2)
add(lines, "/* End PBXNativeTarget section */")
add(lines)

add(lines, "/* Begin PBXProject section */")
add(lines, f"{project_id} /* Project object */ = {{", 2)
add(lines, "isa = PBXProject;", 3)
add(lines, "attributes = {", 3)
add(lines, "BuildIndependentTargetsInParallel = YES;", 4)
add(lines, "LastSwiftUpdateCheck = 1500;", 4)
add(lines, "LastUpgradeCheck = 1500;", 4)
add(lines, "TargetAttributes = {", 4)
add(lines, f"{app_target} = {{CreatedOnToolsVersion = 15.0;}};", 5)
add(lines, f"{test_target} = {{CreatedOnToolsVersion = 15.0; TestTargetID = {app_target};}};", 5)
add(lines, "};", 4)
add(lines, "};", 3)
add(lines, f"buildConfigurationList = {project_build_config_list} /* Build configuration list for PBXProject \"JourneyTH\" */;", 3)
add(lines, 'compatibilityVersion = "Xcode 15.0";', 3)
add(lines, "developmentRegion = en;", 3)
add(lines, "hasScannedForEncodings = 0;", 3)
add(lines, "knownRegions = (", 3)
add(lines, "en,", 4)
add(lines, "Base,", 4)
add(lines, "th,", 4)
add(lines, ");", 3)
if package_references:
    add(lines, "packageReferences = (", 3)
    for rid, name, *_ in package_references:
        add(lines, f"{normalize_id(rid)} /* XCRemoteSwiftPackageReference \"{name}\" */,", 4)
    add(lines, ");", 3)
add(lines, f"mainGroup = {main_group_id};", 3)
add(lines, f"productRefGroup = {product_ref_group_id};", 3)
add(lines, 'projectDirPath = "";', 3)
add(lines, 'projectRoot = "";', 3)
add(lines, "targets = (", 3)
add(lines, f"{app_target} /* JourneyTH */,", 4)
add(lines, f"{test_target} /* JourneyTHTests */,", 4)
add(lines, ");", 3)
add(lines, "};", 2)
add(lines, "/* End PBXProject section */")
add(lines)

add(lines, "/* Begin PBXResourcesBuildPhase section */")
add(lines, f"{app_resources_phase} /* Resources */ = {{", 2)
add(lines, "isa = PBXResourcesBuildPhase;", 3)
add(lines, "buildActionMask = 2147483647;", 3)
add(lines, "files = (", 3)
for fid in resource_build_files:
    comment, _, _ = build_file_map[fid]
    add(lines, f"{normalize_id(fid)} /* {comment} */,", 4)
add(lines, ");", 3)
add(lines, "runOnlyForDeploymentPostprocessing = 0;", 3)
add(lines, "};", 2)
add(lines, f"{test_resources_phase} /* Resources */ = {{", 2)
add(lines, "isa = PBXResourcesBuildPhase;", 3)
add(lines, "buildActionMask = 2147483647;", 3)
add(lines, "files = (", 3)
add(lines, ");", 3)
add(lines, "runOnlyForDeploymentPostprocessing = 0;", 3)
add(lines, "};", 2)
add(lines, "/* End PBXResourcesBuildPhase section */")
add(lines)

add(lines, "/* Begin PBXSourcesBuildPhase section */")
add(lines, f"{app_sources_phase} /* Sources */ = {{", 2)
add(lines, "isa = PBXSourcesBuildPhase;", 3)
add(lines, "buildActionMask = 2147483647;", 3)
add(lines, "files = (", 3)
for fid in app_sources:
    comment, _, _ = build_file_map[fid]
    add(lines, f"{normalize_id(fid)} /* {comment} */,", 4)
add(lines, ");", 3)
add(lines, "runOnlyForDeploymentPostprocessing = 0;", 3)
add(lines, "};", 2)
add(lines, f"{test_sources_phase} /* Sources */ = {{", 2)
add(lines, "isa = PBXSourcesBuildPhase;", 3)
add(lines, "buildActionMask = 2147483647;", 3)
add(lines, "files = (", 3)
for fid, _, _, _ in test_build_files:
    comment, _, _ = build_file_map[fid]
    add(lines, f"{normalize_id(fid)} /* {comment} */,", 4)
add(lines, ");", 3)
add(lines, "runOnlyForDeploymentPostprocessing = 0;", 3)
add(lines, "};", 2)
add(lines, "/* End PBXSourcesBuildPhase section */")
add(lines)

add(lines, "/* Begin PBXTargetDependency section */")
add(lines, f"{target_dependency_id} /* PBXTargetDependency */ = {{", 2)
add(lines, f"isa = PBXTargetDependency;", 3)
add(lines, f"target = {app_target} /* JourneyTH */;", 3)
add(lines, f"targetProxy = {container_proxy_id} /* PBXContainerItemProxy */;", 3)
add(lines, "};", 2)
add(lines, "/* End PBXTargetDependency section */")
add(lines)

add(lines, "/* Begin PBXVariantGroup section */")
add(lines, f"{normalize_id(variant_group_id)} /* {variant_name} */ = {{", 2)
add(lines, "isa = PBXVariantGroup;", 3)
add(lines, "children = (", 3)
for child in variant_children:
    child_comment = file_refs[child][0]
    add(lines, f"{normalize_id(child)} /* {child_comment} */,", 4)
add(lines, ");", 3)
add(lines, f"name = {variant_name};", 3)
add(lines, 'sourceTree = "<group>";', 3)
add(lines, "};", 2)
add(lines, "/* End PBXVariantGroup section */")
add(lines)

if package_product_dependencies:
    add(lines, "/* Begin XCSwiftPackageProductDependency section */")
    for pid, name, package_id in package_product_dependencies:
        package_name = package_reference_map[package_id][0]
        add(lines, f"{normalize_id(pid)} /* {name} */ = {{", 2)
        add(lines, "isa = XCSwiftPackageProductDependency;", 3)
        add(lines, f"package = {normalize_id(package_id)} /* XCRemoteSwiftPackageReference \"{package_name}\" */;", 3)
        add(lines, f"productName = {name};", 3)
        add(lines, "};", 2)
    add(lines, "/* End XCSwiftPackageProductDependency section */")
    add(lines)

if package_references:
    add(lines, "/* Begin XCRemoteSwiftPackageReference section */")
    for rid, name, url, min_version, _ in package_references:
        add(lines, f"{normalize_id(rid)} /* XCRemoteSwiftPackageReference \"{name}\" */ = {{", 2)
        add(lines, "isa = XCRemoteSwiftPackageReference;", 3)
        add(lines, f"repositoryURL = \"{url}\";", 3)
        add(lines, "requirement = {", 3)
        add(lines, "kind = upToNextMajorVersion;", 4)
        add(lines, f"minimumVersion = {min_version};", 4)
        add(lines, "};", 3)
        add(lines, "};", 2)
    add(lines, "/* End XCRemoteSwiftPackageReference section */")
    add(lines)

add(lines, "/* Begin XCBuildConfiguration section */")
for identifier, name, settings in [
    (project_debug_config, "Debug", project_debug_settings),
    (project_release_config, "Release", project_release_settings),
    (app_debug_config, "Debug", app_debug_settings),
    (app_release_config, "Release", app_release_settings),
    (test_debug_config, "Debug", test_debug_settings),
    (test_release_config, "Release", test_release_settings),
]:
    add(lines, f"{identifier} /* {name} */ = {{", 2)
    add(lines, "isa = XCBuildConfiguration;", 3)
    add(lines, "buildSettings = {", 3)
    for key, value in settings:
        add(lines, f"{key} = {value};", 4)
    add(lines, "};", 3)
    add(lines, f"name = {name};", 3)
    add(lines, "};", 2)
add(lines, "/* End XCBuildConfiguration section */")
add(lines)

add(lines, "/* Begin XCConfigurationList section */")
add(
    lines,
    f"{project_build_config_list} /* Build configuration list for PBXProject \"JourneyTH\" */ = {{",
    2,
)
add(lines, "isa = XCConfigurationList;", 3)
add(lines, "buildConfigurations = (", 3)
add(lines, f"{project_debug_config} /* Debug */,", 4)
add(lines, f"{project_release_config} /* Release */,", 4)
add(lines, ");", 3)
add(lines, "defaultConfigurationIsVisible = 0;", 3)
add(lines, "defaultConfigurationName = Release;", 3)
add(lines, "};", 2)
add(
    lines,
    f"{app_build_config_list} /* Build configuration list for PBXNativeTarget \"JourneyTH\" */ = {{",
    2,
)
add(lines, "isa = XCConfigurationList;", 3)
add(lines, "buildConfigurations = (", 3)
add(lines, f"{app_debug_config} /* Debug */,", 4)
add(lines, f"{app_release_config} /* Release */,", 4)
add(lines, ");", 3)
add(lines, "defaultConfigurationIsVisible = 0;", 3)
add(lines, "defaultConfigurationName = Release;", 3)
add(lines, "};", 2)
add(
    lines,
    f"{test_build_config_list} /* Build configuration list for PBXNativeTarget \"JourneyTHTests\" */ = {{",
    2,
)
add(lines, "isa = XCConfigurationList;", 3)
add(lines, "buildConfigurations = (", 3)
add(lines, f"{test_debug_config} /* Debug */,", 4)
add(lines, f"{test_release_config} /* Release */,", 4)
add(lines, ");", 3)
add(lines, "defaultConfigurationIsVisible = 0;", 3)
add(lines, "defaultConfigurationName = Release;", 3)
add(lines, "};", 2)
add(lines, "/* End XCConfigurationList section */")
add(lines)

add(lines, "};", 1)
add(lines, f"rootObject = {project_id} /* Project object */;", 1)
add(lines, "}")

with open("JourneyTH.xcodeproj/project.pbxproj", "w") as f:
    f.write("\n".join(lines) + "\n")

if package_references:
    resolved = {
        "pins": [
            {
                "identity": name,
                "kind": "remoteSourceControl",
                "location": url,
                "state": {
                    "revision": revision,
                    "version": min_version,
                },
            }
            for _, name, url, min_version, revision in package_references
        ],
        "version": 2,
    }
    resolved_path = Path("JourneyTH.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved")
    resolved_path.parent.mkdir(parents=True, exist_ok=True)
    resolved_path.write_text(json.dumps(resolved, indent=2) + "\n")
