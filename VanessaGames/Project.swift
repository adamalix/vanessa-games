import ProjectDescription

let project = Project(
    name: "VanessaGames",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.1",
            "SWIFT_STRICT_CONCURRENCY": "complete",
            "SWIFT_UPCOMING_FEATURE_CONCISE_MAGIC_FILE": "YES",
            "SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES": "YES",
            "SWIFT_UPCOMING_FEATURE_EXISTENTIAL_ANY": "YES",
            "SWIFT_UPCOMING_FEATURE_BARE_SLASH_REGEX_LITERALS": "YES",
            "SWIFT_UPCOMING_FEATURE_DEPRECATE_APPLICATION_MAIN": "YES",
            "SWIFT_UPCOMING_FEATURE_ISOLATED_DEFAULT_VALUES": "YES",
            "SWIFT_UPCOMING_FEATURE_GLOBAL_ACTOR_ISOLATED_TYPEALIAS": "YES"
        ]
    ),
    targets: [
        // MARK: - Shared Frameworks
        .target(
            name: "SharedGameEngine",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.vanessagames.SharedGameEngine",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Shared/GameEngine/Sources/**"],
            dependencies: []
        ),
        .target(
            name: "SharedAssets",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.vanessagames.SharedAssets",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Shared/Assets/Sources/**"],
            resources: ["Shared/Assets/Resources/**"],
            dependencies: []
        ),

        // MARK: - Games
        .target(
            name: "ClausyTheCloud",
            destinations: .iOS,
            product: .app,
            bundleId: "com.vanessagames.ClausyTheCloud",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Clausy the Cloud",
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
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
            sources: ["Games/ClausyTheCloud/Sources/**"],
            resources: ["Games/ClausyTheCloud/Resources/**"],
            dependencies: [
                .target(name: "SharedGameEngine"),
                .target(name: "SharedAssets")
            ]
        ),

        // MARK: - Tests
        .target(
            name: "SharedGameEngineTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.vanessagames.SharedGameEngineTests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Shared/GameEngine/Tests/**"],
            dependencies: [.target(name: "SharedGameEngine")]
        ),
        .target(
            name: "ClausyTheCloudTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.vanessagames.ClausyTheCloudTests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Games/ClausyTheCloud/Tests/**"],
            dependencies: [
                .target(name: "ClausyTheCloud"),
                .target(name: "SharedGameEngine")
            ]
        ),
    ],
    schemes: [
        .scheme(
            name: "ClausyTheCloud",
            shared: true,
            buildAction: .buildAction(targets: ["ClausyTheCloud"]),
            testAction: .targets(["ClausyTheCloudTests"]),
            runAction: .runAction(executable: "ClausyTheCloud")
        ),
        .scheme(
            name: "SharedGameEngine",
            shared: true,
            buildAction: .buildAction(targets: ["SharedGameEngine"]),
            testAction: .targets(["SharedGameEngineTests"])
        ),
    ]
)
