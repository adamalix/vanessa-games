import ProjectDescription

let project = Project(
    name: "VanessaGames",
    settings: .settings(
        base: SettingsDictionary()
            .automaticCodeSigning(devTeam: "8373S8M9H3")
            .swiftVersion("6.2")
            .merging([
                "SWIFT_STRICT_CONCURRENCY": "complete",
                "SWIFT_UPCOMING_FEATURE_CONCISE_MAGIC_FILE": "YES",
                "SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES": "YES",
                "SWIFT_UPCOMING_FEATURE_EXISTENTIAL_ANY": "YES",
                "SWIFT_UPCOMING_FEATURE_BARE_SLASH_REGEX_LITERALS": "YES",
                "SWIFT_UPCOMING_FEATURE_DEPRECATE_APPLICATION_MAIN": "YES",
                "SWIFT_UPCOMING_FEATURE_ISOLATED_DEFAULT_VALUES": "YES",
                "SWIFT_UPCOMING_FEATURE_GLOBAL_ACTOR_ISOLATED_TYPEALIAS": "YES",
                "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor"
            ])
    ),
    targets: [
        // MARK: - Shared Frameworks
        .target(
            name: "SharedGameEngine",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.adamalix.vanessagames.sharedgameengine",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            buildableFolders: ["Shared/GameEngine/Sources"],
            dependencies: [
                .external(name: "Dependencies")
            ],
            settings: .settings(
                base: SettingsDictionary()
                    .merging(["SWIFT_DEFAULT_ACTOR_ISOLATION": "nonisolated"])
            )
        ),
        .target(
            name: "SharedAssets",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.adamalix.vanessagames.sharedassets",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            buildableFolders: ["Shared/Assets/Sources", "Shared/Assets/Resources"],
            dependencies: []
        ),

        // MARK: - Games
        .target(
            name: "ClausyTheCloud",
            destinations: .iOS,
            product: .app,
            bundleId: "com.adamalix.vanessagames.clausythecloud",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Clausy the Cloud",
                    "CFBundleIcons": [
                        "CFBundlePrimaryIcon": [
                            "CFBundleIconFiles": [],
                            "CFBundleIconName": "AppIcon"
                        ]
                    ],
                    "CFBundleIcons~ipad": [
                        "CFBundlePrimaryIcon": [
                            "CFBundleIconFiles": [],
                            "CFBundleIconName": "AppIcon"
                        ]
                    ],
                    "LSApplicationCategoryType": "public.app-category.kids-games",
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": ""
                    ],
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ],
                    "UISupportedInterfaceOrientations~ipad": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationPortraitUpsideDown",
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ]
                ]
            ),
            buildableFolders: ["Games/ClausyTheCloud/Sources", "Games/ClausyTheCloud/Resources"],
            scripts: commonScripts(),
            dependencies: [
                .target(name: "SharedGameEngine"),
                .target(name: "SharedAssets"),
                .external(name: "Dependencies")
            ]
        ),

        // MARK: - Tests
        .target(
            name: "SharedGameEngineTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.adamalix.vanessagames.sharedgameenginetests",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            buildableFolders: ["Shared/GameEngine/Tests"],
            dependencies: [
                .target(name: "SharedGameEngine"),
                .external(name: "Dependencies")
            ]
        ),
        .target(
            name: "ClausyTheCloudTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.adamalix.vanessagames.clausythecloudtests",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            buildableFolders: ["Games/ClausyTheCloud/Tests"],
            dependencies: [
                .target(name: "ClausyTheCloud"),
                .target(name: "SharedGameEngine"),
                .external(name: "SnapshotTesting"),
                .external(name: "Dependencies")
            ]
        )
    ],
    schemes: [
        .scheme(
            name: "ClausyTheCloud",
            shared: true,
            buildAction: .buildAction(targets: ["ClausyTheCloud"]),
            testAction: .targets(
                ["ClausyTheCloudTests"],
                arguments: .arguments(
                    environmentVariables: [
                        "CI_XCODE_CLOUD": .environmentVariable(value: "$(CI_XCODE_CLOUD)", isEnabled: true)
                    ]
                )
            ),
            runAction: .runAction(executable: "ClausyTheCloud")
        ),
        .scheme(
            name: "SharedGameEngine",
            shared: true,
            buildAction: .buildAction(targets: ["SharedGameEngine"]),
            testAction: .targets(["SharedGameEngineTests"])
        )
    ]
)

func commonScripts() -> [TargetScript] {
    [
        .pre(
            path: .path("../scripts/swiftlint.sh"),
            name: "SwiftLint",
            basedOnDependencyAnalysis: false
        )
    ]
}
