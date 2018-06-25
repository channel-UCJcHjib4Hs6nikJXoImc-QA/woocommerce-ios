

inhibit_all_warnings!
use_frameworks!

platform :ios, '11.0'
workspace 'WooCommerce.xcworkspace'



# Main Target!
# ============
#
target 'WooCommerce' do
  project 'WooCommerce/WooCommerce.xcodeproj'


  # Automattic Libraries
  # ====================
  #
  pod 'Automattic-Tracks-iOS', :git => 'https://github.com/Automattic/Automattic-Tracks-iOS.git', :tag => '0.2.3'
  pod 'Gridicons', '0.15'
  pod 'WordPressAuthenticator', :git => 'https://github.com/wordpress-mobile/WordPressAuthenticator-iOS.git', :commit => '58ed623'


  # External Libraries
  # ==================
  #
  pod 'Alamofire', '~> 4.7'
  pod 'Crashlytics', '~> 3.10'
  pod 'KeychainAccess', '~> 3.1'
  pod 'CocoaLumberjack/Swift', '~> 3.4'
end



# Yosemite Layer:
# ===============
#
target 'Yosemite' do
  project 'Yosemite/Yosemite.xcodeproj'


  # Unit Tests
  # ==========
  #
  target 'YosemiteTests' do
    inherit! :search_paths
    pod 'Alamofire', '~> 4.7'
  end

end



# Networking Layer:
# =================
#
target 'Networking' do
  project 'Networking/Networking.xcodeproj'


  # External Libraries
  # ==================
  #
  pod 'Alamofire', '~> 4.7'
  pod 'CocoaLumberjack/Swift', '~> 3.4'


  # Unit Tests
  # ==========
  #
  target 'NetworkingTests' do
    inherit! :search_paths
  end
end


# Storage Layer:
# ==============
#
target 'Storage' do
  project 'Storage/Storage.xcodeproj'

  # External Libraries
  # ==================
  #
  pod 'CocoaLumberjack/Swift', '~> 3.4'


  # Unit Tests
  # ==========
  #
  target 'StorageTests' do
    inherit! :search_paths
  end
end
