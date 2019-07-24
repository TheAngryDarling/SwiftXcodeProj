//
//  XcodeBuildConfigurationSettings.swift
//  XcodeProj
//
//  Created by Tyler Anger on 2019-06-13.
//

import Foundation

fileprivate extension Dictionary {
    func mergingKeepNew(_ other: Dictionary<Key,Value>) -> [Key : Value] {
        return self.merging(other) {  (_, keeping) in keeping  }
    }
    func mergingKeepOld(_ other: Dictionary<Key,Value>) -> [Key : Value] {
        return self.merging(other) {  (keeping, _) in keeping  }
    }
}


/// Stores default project settings for different project types
public struct XcodeProjectBuildConfigurationSettings {
    private init() { }
    
    public struct swift {
        private init() { }
        
        public struct PackageManager {
            private init() {}
            public static let BASE: [String: Any] = [
                "CLANG_ENABLE_OBJC_ARC": "YES",
                "COMBINE_HIDPI_IMAGES": "YES",
                "DYLIB_INSTALL_NAME_BASE": "@rpath",
                "MACOSX_DEPLOYMENT_TARGET": "10.10",
                "OTHER_SWIFT_FLAGS": [
                    "-DXcode"
                ],
                "PRODUCT_NAME": "$(TARGET_NAME)",
                "SDKROOT": "macosx",
                "SUPPORTED_PLATFORMS": [
                    "macosx",
                    "iphoneos",
                    "iphonesimulator",
                    "appletvos",
                    "appletvsimulator",
                    "watchos",
                    "watchsimulator"
                ],
                "USE_HEADERMAP": "NO"
            ]
            
            private static let _RELEASE: [String: Any] = [
                "COPY_PHASE_STRIP": "YES",
                "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                "GCC_OPTIMIZATION_LEVEL": "s",
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": [
                    "SWIFT_PACKAGE"
                ],
                "SWIFT_OPTIMIZATION_LEVEL": "-Owholemodule"
            ]
            
            private static let _DEBUG: [String: Any] = [
                "COPY_PHASE_STRIP": "NO",
                "DEBUG_INFORMATION_FORMAT": "dwarf",
                "ENABLE_NS_ASSERTIONS": "YES",
                "GCC_OPTIMIZATION_LEVEL": 0,
                "GCC_PREPROCESSOR_DEFINITIONS": [
                    "DEBUG=1",
                    "$(inherited)"
                ],
                "ONLY_ACTIVE_ARCH": "YES",
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": [
                    "SWIFT_PACKAGE",
                    "DEBUG"
                ],
                "SWIFT_OPTIMIZATION_LEVEL": "-Onone"
            ]
            
            public static let RELEASE: [String: Any] = BASE.mergingKeepNew(_RELEASE)
            public static let DEBUG: [String: Any] = BASE.mergingKeepNew(_DEBUG)
            
            public struct exe {
                private init() {}
                
                public static let RELEASE: [String: Any] = PackageManager.RELEASE
                public static let DEBUG: [String: Any] = PackageManager.DEBUG
            }
            
            public struct lib {
                private init() {}
                
                public static let RELEASE: [String: Any] = PackageManager.RELEASE
                public static let DEBUG: [String: Any] = PackageManager.DEBUG
            }
            
            public struct sysMod {
                private init() {}
                
                public static let RELEASE: [String: Any] = PackageManager.RELEASE
                public static let DEBUG: [String: Any] = PackageManager.DEBUG
            }
        }
        
        public struct Mac {
            private init() {}
            public static let BASE: [String: Any] = [
                "ALWAYS_SEARCH_USER_PATHS": "NO",
                "CLANG_ANALYZER_NONNULL": "YES",
                "CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION": "YES_AGGRESSIVE",
                "CLANG_CXX_LANGUAGE_STANDARD": "gnu++14",
                "CLANG_CXX_LIBRARY": "libc++",
                "CLANG_ENABLE_MODULES": "YES",
                "CLANG_ENABLE_OBJC_ARC": "YES",
                "CLANG_ENABLE_OBJC_WEAK": "YES",
                "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": "YES",
                "CLANG_WARN_BOOL_CONVERSION": "YES",
                "CLANG_WARN_COMMA": "YES",
                "CLANG_WARN_CONSTANT_CONVERSION": "YES",
                "CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS": "YES",
                "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": "YES_ERROR",
                "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES",
                "CLANG_WARN_EMPTY_BODY": "YES",
                "CLANG_WARN_ENUM_CONVERSION": "YES",
                "CLANG_WARN_INFINITE_RECURSION": "YES",
                "CLANG_WARN_INT_CONVERSION": "YES",
                "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": "YES",
                "CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF": "YES",
                "CLANG_WARN_OBJC_LITERAL_CONVERSION": "YES",
                "CLANG_WARN_OBJC_ROOT_CLASS": "YES_ERROR",
                "CLANG_WARN_RANGE_LOOP_ANALYSIS": "YES",
                "CLANG_WARN_STRICT_PROTOTYPES": "YES",
                "CLANG_WARN_SUSPICIOUS_MOVE": "YES",
                "CLANG_WARN_UNGUARDED_AVAILABILITY": "YES_AGGRESSIVE",
                "CLANG_WARN_UNREACHABLE_CODE": "YES",
                "CLANG_WARN__DUPLICATE_METHOD_MATCH": "YES",
                "CODE_SIGN_IDENTITY": "-",
                "COPY_PHASE_STRIP": "NO",
                "ENABLE_STRICT_OBJC_MSGSEND": "YES",
                "GCC_C_LANGUAGE_STANDARD": "gnu11",
                "GCC_NO_COMMON_BLOCKS": "YES",
                "GCC_WARN_64_TO_32_BIT_CONVERSION": "YES",
                "GCC_WARN_ABOUT_RETURN_TYPE": "YES_ERROR",
                "GCC_WARN_UNDECLARED_SELECTOR": "YES",
                "GCC_WARN_UNINITIALIZED_AUTOS": "YES_AGGRESSIVE",
                "GCC_WARN_UNUSED_FUNCTION": "YES",
                "GCC_WARN_UNUSED_VARIABLE": "YES",
                "MACOSX_DEPLOYMENT_TARGET": "10.10",
                "MTL_FAST_MATH": "YES",
                "SDKROOT": "macosx"
            ]
            
            private static let _RELEASE: [String: Any] = [
                "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                "ENABLE_NS_ASSERTIONS": "NO",
                "MTL_ENABLE_DEBUG_INFO": "NO",
                "SWIFT_COMPILATION_MODE": "wholemodule",
                "SWIFT_OPTIMIZATION_LEVEL": "-O"
            ]
            
            private static let _DEBUG: [String: Any] = [
                "DEBUG_INFORMATION_FORMAT": "dwarf",
                "ENABLE_TESTABILITY": "YES",
                "GCC_DYNAMIC_NO_PIC": "NO",
                "GCC_OPTIMIZATION_LEVEL": 0,
                "GCC_PREPROCESSOR_DEFINITIONS": [
                    "DEBUG=1",
                    "$(inherited)"
                ],
                "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
                "ONLY_ACTIVE_ARCH": "YES",
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
                "SWIFT_OPTIMIZATION_LEVEL": "-Onone"
            ]
            
            public static let RELEASE: [String: Any] = BASE.mergingKeepNew(_RELEASE)
            public static let DEBUG: [String: Any] = BASE.mergingKeepNew(_DEBUG)
            
            public struct cocoaApp {
                private init() {}
                
                public static let RELEASE: [String: Any] = Mac.RELEASE
                public static let DEBUG: [String: Any] = Mac.DEBUG
            }
            
            public struct cocoaFramework {
                private init() {}
                
                public static let RELEASE: [String: Any] = Mac.RELEASE
                public static let DEBUG: [String: Any] = Mac.DEBUG
            }
            
            public struct commandLine {
                private init() {}
                
                public static let RELEASE: [String: Any] = Mac.RELEASE
                public static let DEBUG: [String: Any] = Mac.DEBUG
            }
            
            public struct game {
                private init() {}
                
                public static let RELEASE: [String: Any] = Mac.RELEASE
                public static let DEBUG: [String: Any] = Mac.DEBUG
            }
            
            public struct safariExtApp {
                private init() {}
                
                public static let RELEASE: [String: Any] = Mac.RELEASE
                public static let DEBUG: [String: Any] = Mac.DEBUG
            }
        }
        
    }
    
    public struct objectiveC {
        private init() { }
        
        public struct Mac {
            private init() {}
            public static let BASE: [String: Any] = [
                "ALWAYS_SEARCH_USER_PATHS": "NO",
                "CODE_SIGN_IDENTITY": "-",
                "MACOSX_DEPLOYMENT_TARGET": "10.10",
                "MTL_FAST_MATH": "YES",
                "SDKROOT": "macosx"
            ]
            
            private static let _RELEASE: [String: Any] = [
                "MTL_ENABLE_DEBUG_INFO": "NO"
            ]
            
            private static let _DEBUG: [String: Any] = [
                "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE"
            ]
            
            public static let RELEASE: [String: Any] = BASE.mergingKeepNew(_RELEASE)
            public static let DEBUG: [String: Any] = BASE.mergingKeepNew(_DEBUG)
            
            public struct automatorAction {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct bundle {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct cocoaApp {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct cocoaFramework {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct commandLine {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct contactsActionPlugin {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct game {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct imageUnitPlugin {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct installerPlugin {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct library {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct metalLibrary {
                private init() {}
                
                public static let RELEASE: [String: Any] = Mac.RELEASE
                public static let DEBUG: [String: Any] = Mac.DEBUG
            }
            
            public struct preferencePane {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct quartsComposerPlugin {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct safariExtApp {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct screenSaver {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
            
            public struct xPCService {
                private init() {}
                
                private static let _RELEASE: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "ENABLE_NS_ASSERTIONS": "NO"
                ]
                
                private static let _DEBUG: [String: Any] = [
                    "DEBUG_INFORMATION_FORMAT": "dwarf",
                    "ENABLE_TESTABILITY": "YES",
                    "GCC_DYNAMIC_NO_PIC": "NO",
                    "GCC_OPTIMIZATION_LEVEL": 0,
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "$(inherited)"
                    ],
                    "ONLY_ACTIVE_ARCH": "YES"
                ]
                
                public static let RELEASE: [String: Any] = Mac.RELEASE.mergingKeepNew(_RELEASE)
                public static let DEBUG: [String: Any] = Mac.DEBUG.mergingKeepNew(_DEBUG)
            }
        }
        
    }
}
