
    def swift_ivar_access_pod
        pod 'SwiftIvarAccess'
    end

    target :AppleGuice do
        swift_ivar_access_pod
    end

    target :AppleGuiceUnitTests do
		platform :ios, '8.0'

        swift_ivar_access_pod
		pod 'OCMock','~> 3.1.1'
		pod 'Expecta','1.0.6'

	end

	target :BootstrapperTests do
		platform :osx, '10.8'

		pod 'Expecta','1.0.6'

	end
