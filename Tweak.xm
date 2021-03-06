#import "Tweak.h"

// Normal Dock

%group SBDockViewPercentage

%hook SBDockView
%property (nonatomic, retain) UIView *percentageView;
%property (nonatomic, assign) float batteryPercentageWidth;
%property (nonatomic, assign) float batteryPercentage;

-(id)initWithDockListView:(id)arg1 forSnapshot:(BOOL)arg2 {
	return theDock = %orig;
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];

	otherTweakPrefs();
	oldDockEnabled();
	navaleDetect();

	if(HomeGestureInstalled ||DockX13Installed ||DockXInstalled ||MultiplaInstalled){
		XDock = NO;
	}
}

-(void)layoutSubviews { 
	%orig;

	otherTweakPrefs();
	oldDockEnabled();
	navaleDetect();

	[self updateBatteryViewWidth:nil];
	if((isNotchedDevice ||(XDock && !isNotchedDevice) ||HomeGestureInstalled ||(DockXInstalled && DockXIXDock) ||DockX13Installed ||(MultiplaInstalled && MultiplaXDock)) && !oldDockIsEnabled){
		CAShapeLayer *maskLayer = [CAShapeLayer layer];
		CGFloat cornerRadiusValueForBeizer;
		if(NavaleInstalled){
			NSDictionary *navalePrefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.lacertosusrepo.navaleprefs"];
			cornerRadiusOnNavaleEnabled = [[navalePrefs objectForKey:@"overrideCornerRadius"] boolValue];
			navaleCornerRadiusValue = [[navalePrefs objectForKey:@"cornerRadius"] doubleValue];
			if(cornerRadiusOnNavaleEnabled){
				cornerRadiusValueForBeizer = navaleCornerRadiusValue;
			} else {
				cornerRadiusValueForBeizer = backgroundView.layer.cornerRadius;
			}
		} else {
			cornerRadiusValueForBeizer = backgroundView.layer.cornerRadius;
		}
		maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:backgroundView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:(CGSize){cornerRadiusValueForBeizer, cornerRadiusValueForBeizer}].CGPath;
		self.percentageView.layer.mask = maskLayer;
	}
}

-(void)didMoveToWindow {
	%orig;
	oldDockEnabled();
	[self addPercentageBatteryView];

	if([backgroundView respondsToSelector:@selector(_materialLayer)]){
		((MTMaterialView *)backgroundView).weighting = hideBgView ? 0 : 1;
	}

	if([backgroundView respondsToSelector:@selector(blurView)]){
		((SBWallpaperEffectView *)backgroundView).blurView.hidden = hideBgView ? YES : NO;
	}
}

%new 
-(void)updateBatteryViewWidth:(NSNotification *)notification {
	otherTweakPrefs();
	oldDockEnabled();

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		backgroundView = [self valueForKey:@"backgroundView"];

		float percentageViewHeight;
		if(isNotchedDevice ||(XDock && !isNotchedDevice) ||HomeGestureInstalled ||(DockXInstalled && DockXIXDock) ||DockX13Installed ||(MultiplaInstalled && MultiplaXDock)){
			percentageViewHeight = backgroundView.bounds.size.height;
		} else {
			if(oldDockIsEnabled){
				percentageViewHeight = backgroundView.bounds.size.height + 1;
			} else {
				percentageViewHeight = self.bounds.size.height - 4;
			}
		}
		float percentageViewY = (isNotchedDevice ||(XDock && !isNotchedDevice) ||HomeGestureInstalled ||(DockXInstalled && DockXIXDock) ||DockX13Installed ||(MultiplaInstalled && MultiplaXDock)) ? 0 : 4;

    	if(!customPercentEnabled){
			self.batteryPercentage = [[UIDevice currentDevice] batteryLevel] * 100;
		} else {
			self.batteryPercentage = customPercent;
		}
		if((isNotchedDevice || (XDock && !isNotchedDevice) ||HomeGestureInstalled ||DockXInstalled ||DockX13Installed ||(MultiplaInstalled && MultiplaXDock)) && !oldDockIsEnabled){
			self.batteryPercentageWidth = (self.batteryPercentage * (backgroundView.bounds.size.width)) / 100;
		} else {
			self.batteryPercentageWidth = (self.batteryPercentage * (self.bounds.size.width)) / 100;
		}

		darkModeIsEnabled = [self darkModeEnabled];
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[UIView animateWithDuration:0.2
                 animations:^{
				self.percentageView.frame = CGRectMake(0,percentageViewY,self.batteryPercentageWidth,percentageViewHeight);

				if([backgroundView respondsToSelector:@selector(_materialLayer)]){
					((MTMaterialView *)backgroundView).weighting = hideBgView ? 0 : 1;
				}

				if([backgroundView respondsToSelector:@selector(blurView)]){
					((SBWallpaperEffectView *)backgroundView).blurView.hidden = hideBgView ? YES : NO;
				}

				if(!disableColoring){
					if(differencColorDarkModeEnabled){
						if(!darkModeIsEnabled){
							if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
								if([lowPowerModeHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
								}
							} else if(self.batteryPercentage <= 20){
								if([lowBatteryHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 2){
								if([chargingHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
								self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
							} else {
								if([defaultHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
								}
							}
						} else {
							if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
								if([lowPowerModeHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
								}
							} else if(self.batteryPercentage <= 20){
								if([lowBatteryHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
								}
							} else if([[UIDevice currentDevice] batteryState] == 2){
								if([chargingHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
								}
							} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
								self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
							} else {
								if([defaultHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
								}
							}
						}
					} else {
						if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
								if([lowPowerModeHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
								}
							} else if(self.batteryPercentage <= 20){
								if([lowBatteryHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 2){
								if([chargingHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
								self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
							} else {
								if([defaultHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
								}
							}
					}
				} else {
					if(differencColorDarkModeEnabled){
						if(!darkModeIsEnabled){
							if([defaultHexCode isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
							}
						} else {
							if([defaultHexCodeDark isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
							}
						}
					} else {
						if([defaultHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
				}
			}];
		});
	});
}

%new
-(void)addPercentageBatteryView {
	otherTweakPrefs();
	oldDockEnabled();

	backgroundView = [self valueForKey:@"backgroundView"];

	float percentageViewHeight;
	if(isNotchedDevice ||(XDock && !isNotchedDevice) ||HomeGestureInstalled ||(DockXInstalled && DockXIXDock) ||DockX13Installed ||(MultiplaInstalled && MultiplaXDock)){
		percentageViewHeight = backgroundView.bounds.size.height;
	} else {
		if(oldDockIsEnabled){
			percentageViewHeight = backgroundView.bounds.size.height + 1;
		} else {
			percentageViewHeight = self.bounds.size.height - 4;
		}
	}
	float percentageViewY = (isNotchedDevice ||(XDock && !isNotchedDevice) ||HomeGestureInstalled ||(DockXInstalled && DockXIXDock) ||DockX13Installed ||(MultiplaInstalled && MultiplaXDock)) ? 0 : 4;

	if(!self.percentageView){

		[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(updateBatteryViewWidth:)
				name:@"CenamoInfoChanged"
				object:nil];

		self.percentageView = [[UIView alloc] initWithFrame:CGRectMake(0,percentageViewY,self.batteryPercentageWidth,percentageViewHeight)];
		self.percentageView.alpha = alphaForBatteryView;

		self.percentageView.layer.masksToBounds = YES;
		self.percentageView.layer.cornerRadius = rounderCornersRadius;

		darkModeIsEnabled = [self darkModeEnabled];

		if(!disableColoring){
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
						self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
					} else {
						if([defaultHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
				} else {
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
						}
					} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
						self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
					} else {
						if([defaultHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
						}
					}
				}
			} else {
				if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
						self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
					} else {
						if([defaultHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
			}
		} else {
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if([defaultHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
					}
				} else {
					if([defaultHexCodeDark isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
					}
				}
			} else {
				if([defaultHexCode isEqualToString:@""]){
					self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
				} else {
					self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
				}
			}
		}
		
		if(isNotchedDevice || (XDock && !isNotchedDevice) ||HomeGestureInstalled ||DockXInstalled ||DockX13Installed ||(MultiplaInstalled && MultiplaXDock)){
			if(oldDockIsEnabled){
				[backgroundView addSubview:self.percentageView];
			} else {
				[backgroundView addSubview:self.percentageView];
			}	
		} else {
			[self insertSubview:self.percentageView aboveSubview:backgroundView];
		}

		[self updateBatteryViewWidth:nil];
	}
}

%new
-(BOOL)darkModeEnabled {
	BOOL enabled = FALSE;
    if(NSClassFromString(@"UIUserInterfaceStyleArbiter")){
        if([[NSClassFromString(@"UIUserInterfaceStyleArbiter") sharedInstance] currentStyle] == 2){
            enabled = TRUE;
        } else {
            enabled = FALSE;
        }
    } else {
        if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Noctis12.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.noctis12prefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        } else if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/NoctisXI.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.NoctisXIprefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        }
    }

    return enabled;
}

%end
%end

%group SBDockViewTint
%hook SBDockView
%property (nonatomic, retain) UIView *percentageView;
%property (nonatomic, assign) float batteryPercentage;

-(id)initWithDockListView:(id)arg1 forSnapshot:(BOOL)arg2 {
	return theDock = %orig;
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];

	otherTweakPrefs();
	oldDockEnabled();
	navaleDetect();

	if(HomeGestureInstalled ||DockX13Installed ||DockXInstalled ||MultiplaInstalled){
		XDock = NO;
	}
}

-(void)layoutSubviews {
	%orig;

	otherTweakPrefs();
	oldDockEnabled();
	navaleDetect();

	[self updateBatteryViewWidth:nil];
	if((isNotchedDevice ||(XDock && !isNotchedDevice) ||HomeGestureInstalled ||(DockXInstalled && DockXIXDock) ||DockX13Installed ||(MultiplaInstalled && MultiplaXDock)) && !oldDockIsEnabled){
		CAShapeLayer *maskLayer = [CAShapeLayer layer];
		CGFloat cornerRadiusValueForBeizer;
		if(NavaleInstalled){
			NSDictionary *navalePrefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.lacertosusrepo.navaleprefs"];
			cornerRadiusOnNavaleEnabled = [[navalePrefs objectForKey:@"overrideCornerRadius"] boolValue];
			navaleCornerRadiusValue = [[navalePrefs objectForKey:@"cornerRadius"] doubleValue];
			if(cornerRadiusOnNavaleEnabled){
				cornerRadiusValueForBeizer = navaleCornerRadiusValue;
			} else {
				cornerRadiusValueForBeizer = backgroundView.layer.cornerRadius;
			}
		} else {
			cornerRadiusValueForBeizer = backgroundView.layer.cornerRadius;
		}
		maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:backgroundView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:(CGSize){cornerRadiusValueForBeizer, cornerRadiusValueForBeizer}].CGPath;
		self.percentageView.layer.mask = maskLayer;
	}
}

-(void)didMoveToWindow {
	%orig;
	[self addPercentageBatteryView];

	if([backgroundView respondsToSelector:@selector(_materialLayer)]){
		((MTMaterialView *)backgroundView).weighting = hideBgView ? 0 : 1;
	}

	if([backgroundView respondsToSelector:@selector(blurView)]){
		((SBWallpaperEffectView *)backgroundView).blurView.hidden = hideBgView ? YES : NO;
	}
}

%new 
-(void)updateBatteryViewWidth:(NSNotification *)notification {
	oldDockEnabled();
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		if(!customPercentEnabled){
			self.batteryPercentage = [[UIDevice currentDevice] batteryLevel] * 100;
		} else {
			self.batteryPercentage = customPercent;
		}

		float percentageViewHeight;
		if(!oldDockIsEnabled){
			percentageViewHeight = backgroundView.bounds.size.height;
		} else {
			percentageViewHeight = backgroundView.bounds.size.height + 1;
		}

		darkModeIsEnabled = [self darkModeEnabled];
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[UIView animateWithDuration:0.2
                 animations:^{
					self.percentageView.frame = CGRectMake(0,0,backgroundView.bounds.size.width,percentageViewHeight);

					if([backgroundView respondsToSelector:@selector(_materialLayer)]){
						((MTMaterialView *)backgroundView).weighting = hideBgView ? 0 : 1;
					}

					if([backgroundView respondsToSelector:@selector(blurView)]){
						((SBWallpaperEffectView *)backgroundView).blurView.hidden = hideBgView ? YES : NO;
					}

					if(!disableColoring){
						if(differencColorDarkModeEnabled){
							if(!darkModeIsEnabled){
								if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
									if([lowPowerModeHexCode isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
									}
								} else if([[UIDevice currentDevice] batteryState] == 2){
									if([chargingHexCode isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
									}
								} else if(self.batteryPercentage <= 20){
									if([lowBatteryHexCode isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
									}
								} else {
									if([defaultHexCode isEqualToString:@""]){
										if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
											self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
										} else {
											self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
										}
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
									}
								}
							} else {
								if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
									if([lowPowerModeHexCodeDark isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
									}
								} else if([[UIDevice currentDevice] batteryState] == 2){
									if([chargingHexCodeDark isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
									}
								} else if(self.batteryPercentage <= 20){
									if([lowBatteryHexCodeDark isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
									}
								} else {
									if([defaultHexCodeDark isEqualToString:@""]){
										if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
											self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
										} else {
											self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
										}
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
									}
								}
							}
						} else {
							if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
									if([lowPowerModeHexCode isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
									}
								} else if([[UIDevice currentDevice] batteryState] == 2){
									if([chargingHexCode isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
									}
								} else if(self.batteryPercentage <= 20){
									if([lowBatteryHexCode isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
									}
								} else {
									if([defaultHexCode isEqualToString:@""]){
										if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
											self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
										} else {
											self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
										}
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
									}
								}
						}
					} else {
						if(differencColorDarkModeEnabled){
							if(!darkModeIsEnabled){
								if([defaultHexCode isEqualToString:@""]){
									if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
										self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
									}
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
								}
							} else {
								if([defaultHexCodeDark isEqualToString:@""]){
									if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
										self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
									}
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
								}
							}
						} else {
							if([defaultHexCode isEqualToString:@""]){
								if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
									self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
								}
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
							}
						}
					}
			}];
		});
	});
}

%new
-(void)addPercentageBatteryView {
	otherTweakPrefs();
	oldDockEnabled();

	backgroundView = [self valueForKey:@"backgroundView"];

	if(isNotchedDevice ||(XDock && !isNotchedDevice) ||HomeGestureInstalled ||(DockXInstalled && DockXIXDock) ||DockX13Installed ||(MultiplaInstalled && MultiplaXDock)){

		CAShapeLayer *maskLayer = [CAShapeLayer layer];
		maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:backgroundView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:(CGSize){backgroundView.layer.cornerRadius, backgroundView.layer.cornerRadius}].CGPath;
		self.percentageView.layer.mask = maskLayer;
	}

	if(!self.percentageView){
		[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(updateBatteryViewWidth:)
				name:@"CenamoInfoChanged"
				object:nil];

		float percentageViewHeight;
		if(!oldDockIsEnabled){
			percentageViewHeight = backgroundView.bounds.size.height;
		} else {
			percentageViewHeight = self.bounds.size.height + 1.5;
		}

		self.percentageView = [[UIView alloc]initWithFrame:CGRectMake(0,0,backgroundView.bounds.size.width,percentageViewHeight)];
		self.percentageView.alpha = alphaForBatteryView;

		darkModeIsEnabled = [self darkModeEnabled];

		if(!disableColoring){
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
						}
					} else {
						if([defaultHexCode isEqualToString:@""]){
							if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
								self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
							}
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
				} else {
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
						}
					} else {
						if([defaultHexCodeDark isEqualToString:@""]){
							if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
								self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
							}
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
						}
					}
				}
			} else {
				if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
						}
					} else {
						if([defaultHexCode isEqualToString:@""]){
							if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
								self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
							}
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
			}
		} else {
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if([defaultHexCode isEqualToString:@""]){
						if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
							self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						}
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
					}
				} else {
					if([defaultHexCodeDark isEqualToString:@""]){
						if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
							self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
						}
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
					}
				}
			} else {
				if([defaultHexCode isEqualToString:@""]){
					if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
						self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
					}
				} else {
					self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
				}
			}
		}

		[backgroundView addSubview:self.percentageView];
	}
}

%new
-(BOOL)darkModeEnabled {
	BOOL enabled = FALSE;
    if(NSClassFromString(@"UIUserInterfaceStyleArbiter")){
        if([[NSClassFromString(@"UIUserInterfaceStyleArbiter") sharedInstance] currentStyle] == 2){
            enabled = TRUE;
        } else {
            enabled = FALSE;
        }
    } else {
        if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Noctis12.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.noctis12prefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        } else if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/NoctisXI.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.NoctisXIprefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        }
    }

    return enabled;
}

%end
%end

%group SBFloatingDockViewPercentage
%hook SBFloatingDockPlatterView
%property (nonatomic, retain) UIView *percentageView;
%property (nonatomic, assign) float batteryPercentageWidth;
%property (nonatomic, assign) float batteryPercentage;

-(id)initWithFrame:(CGRect)arg1 {
	return floatingDock = %orig;
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];

	XDock = NO;
}

-(id)initWithReferenceHeight:(double)arg1 maximumContinuousCornerRadius:(double)arg2 {
	return floatingDock = %orig;
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];

	XDock = NO;
} 

-(void)layoutSubviews {
	%orig;

	[self addPercentageBatteryView];
	[self updateBatteryViewWidth:nil];

	CAShapeLayer *maskLayer = [CAShapeLayer layer];
	maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.backgroundView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:(CGSize){self.backgroundView.layer.cornerRadius, self.backgroundView.layer.cornerRadius}].CGPath;
	self.percentageView.layer.mask = maskLayer;
}

%new 
-(void)updateBatteryViewWidth:(NSNotification *)notification {
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    	if(!customPercentEnabled){
			self.batteryPercentage = [[UIDevice currentDevice] batteryLevel] * 100;
		} else {
			self.batteryPercentage = customPercent;
		}
		float percentageViewHeight = self.backgroundView.bounds.size.height;
		self.batteryPercentageWidth = (self.batteryPercentage * (self.backgroundView.bounds.size.width)) / 100;

		darkModeIsEnabled = [self darkModeEnabled];
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[UIView animateWithDuration:0.2
                 animations:^{
				self.percentageView.frame = CGRectMake(0,0,self.batteryPercentageWidth,percentageViewHeight);

				if(!disableColoring){
					if(differencColorDarkModeEnabled){
						if(!darkModeIsEnabled){
							if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
								if([lowPowerModeHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
								}
							} else if(self.batteryPercentage <= 20){
								if([lowBatteryHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 2){
								if([chargingHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
								self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
							} else {
								if([defaultHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
								}
							}
						} else {
							if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
								if([lowPowerModeHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
								}
							} else if(self.batteryPercentage <= 20){
								if([lowBatteryHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
								}
							} else if([[UIDevice currentDevice] batteryState] == 2){
								if([chargingHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
								}
							} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
								self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
							} else {
								if([defaultHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
								}
							}
						} 
					} else {
						if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
								if([lowPowerModeHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
								}
							} else if(self.batteryPercentage <= 20){
								if([lowBatteryHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 2){
								if([chargingHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
								self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
							} else {
								if([defaultHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
								}
							}
					}
				} else {
					if(differencColorDarkModeEnabled){
						if(!darkModeIsEnabled){
							if([defaultHexCode isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
							}
						} else {
							if([defaultHexCodeDark isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
							}
						}
					} else {
						if([defaultHexCode isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
							}
					}
				}
			}];
		});
	});
}

%new
-(void)addPercentageBatteryView {
	if(!self.percentageView){

		[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(updateBatteryViewWidth:)
				name:@"CenamoInfoChanged"
				object:nil];

		float percentageViewHeight = self.backgroundView.bounds.size.height;
		self.batteryPercentageWidth = (self.batteryPercentage * (self.backgroundView.bounds.size.width)) / 100;

		self.percentageView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.batteryPercentageWidth,percentageViewHeight)];
		self.percentageView.alpha = alphaForBatteryView;

		self.percentageView.layer.masksToBounds = YES;
		self.percentageView.layer.cornerRadius = rounderCornersRadius;

		darkModeIsEnabled = [self darkModeEnabled];

		if(!disableColoring){
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
						self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
					} else {
						if([defaultHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
				} else {
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
						}
					} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
						self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
					} else {
						if([defaultHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
						}
					}
				} 
			} else {
				if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
						self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
					} else {
						if([defaultHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
			}
		} else {
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if([defaultHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
					}
				} else {
					if([defaultHexCodeDark isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
					}
				}
			} else {
				if([defaultHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
					}
			}
		}
		
		[self.backgroundView addSubview:self.percentageView];

		[self updateBatteryViewWidth:nil];
	}
}

%new
-(BOOL)darkModeEnabled {
	BOOL enabled = FALSE;
    if(NSClassFromString(@"UIUserInterfaceStyleArbiter")){
        if([[NSClassFromString(@"UIUserInterfaceStyleArbiter") sharedInstance] currentStyle] == 2){
            enabled = TRUE;
        } else {
            enabled = FALSE;
        }
    } else {
        if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Noctis12.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.noctis12prefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        } else if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/NoctisXI.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.NoctisXIprefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        }
    }

    return enabled;
}

%end
%end

%group SBFloatingDockViewTint
%hook SBFloatingDockPlatterView
%property (nonatomic, retain) UIView *percentageView;
%property (nonatomic, assign) float batteryPercentageWidth;
%property (nonatomic, assign) float batteryPercentage;

-(id)initWithFrame:(CGRect)arg1 {
	return floatingDock = %orig;
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];

	XDock = NO;
}

-(id)initWithReferenceHeight:(double)arg1 maximumContinuousCornerRadius:(double)arg2 {
	return floatingDock = %orig;
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];

	XDock = NO;
}

-(void)layoutSubviews {
	%orig;

	[self addPercentageBatteryView];
	[self updateBatteryViewWidth:nil];

	CAShapeLayer *maskLayer = [CAShapeLayer layer];
	maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.backgroundView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:(CGSize){self.backgroundView.layer.cornerRadius, self.backgroundView.layer.cornerRadius}].CGPath;
	self.percentageView.layer.mask = maskLayer;
}

%new 
-(void)updateBatteryViewWidth:(NSNotification *)notification {
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    	if(!customPercentEnabled){
			self.batteryPercentage = [[UIDevice currentDevice] batteryLevel] * 100;
		} else {
			self.batteryPercentage = customPercent;
		}
		float percentageViewHeight = self.backgroundView.bounds.size.height;
		self.batteryPercentageWidth = self.backgroundView.bounds.size.width;

		darkModeIsEnabled = [self darkModeEnabled];
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[UIView animateWithDuration:0.2
                 animations:^{
				self.percentageView.frame = CGRectMake(0,0,self.batteryPercentageWidth,percentageViewHeight);

				if(!disableColoring){
					if(differencColorDarkModeEnabled){
						if(!darkModeIsEnabled){
							if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
								if([lowPowerModeHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 2){
								if([chargingHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
								}
							} else if(self.batteryPercentage <= 20){
								if([lowBatteryHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
								}
							} else {
								if([defaultHexCode isEqualToString:@""]){
									if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
										self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
									}
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
								}
							}
						} else {
							if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
								if([lowPowerModeHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
								}
							} else if([[UIDevice currentDevice] batteryState] == 2){
								if([chargingHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
								}
							} else if(self.batteryPercentage <= 20){
								if([lowBatteryHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
								}
							} else {
								if([defaultHexCodeDark isEqualToString:@""]){
									if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
										self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
									}
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
								}
							}
						}
					} else {
						if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
							if([lowPowerModeHexCode isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
							}
						} else if([[UIDevice currentDevice] batteryState] == 2){
							if([chargingHexCode isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
							}
						} else if(self.batteryPercentage <= 20){
							if([lowBatteryHexCode isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
							}
						} else {
							if([defaultHexCode isEqualToString:@""]){
								if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
									self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
								}
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
							}
						}
					}
				} else {
					if(differencColorDarkModeEnabled){
						if(!darkModeIsEnabled){
							if([defaultHexCode isEqualToString:@""]){
								if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
									self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
								}
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
							}
						} else {
							if([defaultHexCodeDark isEqualToString:@""]){
								if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
									self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
								}
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
							}
						}
					} else {
						if([defaultHexCode isEqualToString:@""]){
							if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
								self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
							}
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
				}
			}];
		});
	});

}

%new
-(void)addPercentageBatteryView {
	if(!self.percentageView){

		[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(updateBatteryViewWidth:)
				name:@"CenamoInfoChanged"
				object:nil];

		float percentageViewHeight = self.backgroundView.bounds.size.height;
		self.batteryPercentageWidth = self.backgroundView.bounds.size.width;

		self.percentageView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.batteryPercentageWidth,percentageViewHeight)];
		self.percentageView.alpha = alphaForBatteryView;

		self.percentageView.layer.masksToBounds = YES;
		self.percentageView.layer.cornerRadius = rounderCornersRadius;

		darkModeIsEnabled = [self darkModeEnabled];

		if(!disableColoring){
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
						}
					} else {
						if([defaultHexCode isEqualToString:@""]){
							if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
								self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
							}
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
				} else {
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
						}
					} else {
						if([defaultHexCodeDark isEqualToString:@""]){
							if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
								self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
							}
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
						}
					}
				}
			} else {
				if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
					if([lowPowerModeHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
					}
				} else if([[UIDevice currentDevice] batteryState] == 2){
					if([chargingHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
					}
				} else if(self.batteryPercentage <= 20){
					if([lowBatteryHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
					}
				} else {
					if([defaultHexCode isEqualToString:@""]){
						if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
							self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						}
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
					}
				}
			}
		} else {
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if([defaultHexCode isEqualToString:@""]){
						if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
							self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						}
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
					}
				} else {
					if([defaultHexCodeDark isEqualToString:@""]){
						if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
							self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
						}
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
					}
				}
			} else {
				if([defaultHexCode isEqualToString:@""]){
					if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
						self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
					}
				} else {
					self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
				}
			}
		}
		
		[self.backgroundView addSubview:self.percentageView];

		[self updateBatteryViewWidth:nil];
	}
}

%new
-(BOOL)darkModeEnabled {
	BOOL enabled = FALSE;
    if(NSClassFromString(@"UIUserInterfaceStyleArbiter")){
        if([[NSClassFromString(@"UIUserInterfaceStyleArbiter") sharedInstance] currentStyle] == 2){
            enabled = TRUE;
        } else {
            enabled = FALSE;
        }
    } else {
        if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Noctis12.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.noctis12prefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        } else if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/NoctisXI.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.NoctisXIprefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        }
    }

    return enabled;
}
%end
%end

// Aperio support

%group AperioPercentage
%hook APEPlaceholder
%property (nonatomic, retain) UIView *percentageView;
%property (nonatomic, assign) float batteryPercentageWidth;
%property (nonatomic, assign) float batteryPercentage;

-(void)layoutSubviews {
	%orig;
	[self updateBatteryViewWidth:nil];
}

-(void)didMoveToWindow {
	%orig;
	[self addPercentageBatteryView];
}

%new 
-(void)updateBatteryViewWidth:(NSNotification *)notification {

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

		float percentageViewHeight = self.bounds.size.height;
		float percentageViewY = 0;

    	if(!customPercentEnabled){
			self.batteryPercentage = [[UIDevice currentDevice] batteryLevel] * 100;
		} else {
			self.batteryPercentage = customPercent;
		}
		self.batteryPercentageWidth = (self.batteryPercentage * (self.bounds.size.width)) / 100;

		darkModeIsEnabled = [self darkModeEnabled];

		dispatch_async(dispatch_get_main_queue(), ^(void){
			[UIView animateWithDuration:0.2
                 animations:^{
				self.percentageView.frame = CGRectMake(0,percentageViewY,self.batteryPercentageWidth,percentageViewHeight);

				if(!disableColoring){
					if(differencColorDarkModeEnabled){
						if(!darkModeIsEnabled){
							if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
								if([lowPowerModeHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
								}
							} else if(self.batteryPercentage <= 20){
								if([lowBatteryHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 2){
								if([chargingHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
								self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
							} else {
								if([defaultHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
								}
							}
						} else {
							if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
								if([lowPowerModeHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
								}
							} else if(self.batteryPercentage <= 20){
								if([lowBatteryHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
								}
							} else if([[UIDevice currentDevice] batteryState] == 2){
								if([chargingHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
								}
							} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
								self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
							} else {
								if([defaultHexCodeDark isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
								}
							}
						}
					} else {
						if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
							if([lowPowerModeHexCode isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
							}
						} else if(self.batteryPercentage <= 20){
							if([lowBatteryHexCode isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
							}
						} else if([[UIDevice currentDevice] batteryState] == 2){
							if([chargingHexCode isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
							}
						} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
							self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
						} else {
							if([defaultHexCode isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
							}
						}
					}
				} else {
					if(differencColorDarkModeEnabled){
						if(!darkModeIsEnabled){
							if([defaultHexCode isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
							}
						} else {
							if([defaultHexCodeDark isEqualToString:@""]){
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
							}
						}
					} else {
						if([defaultHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
				}
			}];
		});
	});
}

%new
-(void)addPercentageBatteryView {

	float percentageViewHeight = self.bounds.size.height;
		float percentageViewY = 0;

	if(!self.percentageView){

		[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(updateBatteryViewWidth:)
				name:@"CenamoInfoChanged"
				object:nil];

		self.percentageView = [[UIView alloc] initWithFrame:CGRectMake(0,percentageViewY,self.batteryPercentageWidth,percentageViewHeight)];
		self.percentageView.alpha = aperioAlphaForBatteryView;

		self.percentageView.layer.masksToBounds = YES;
		self.percentageView.layer.cornerRadius = aperioRounderCornersRadius;

		darkModeIsEnabled = [self darkModeEnabled];

		if(!disableColoring){
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
						self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
					} else {
						if([defaultHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
				} else {
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
						}
					} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
						self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
					} else {
						if([defaultHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
						}
					}
				}
			} else {
				if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
					if([lowPowerModeHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
					}
				} else if(self.batteryPercentage <= 20){
					if([lowBatteryHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
					}
				} else if([[UIDevice currentDevice] batteryState] == 2){
					if([chargingHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
					}
				} else if([[UIDevice currentDevice] batteryState] == 1 && self.batteryPercentage == 100 && transparentHundred){
					self.percentageView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
				} else {
					if([defaultHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
					}
				}
			}
		} else {
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if([defaultHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
					}
				} else {
					if([defaultHexCodeDark isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
					}
				}
			} else {
				if([defaultHexCode isEqualToString:@""]){
					self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
				} else {
					self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
				}
			}
		}
		
		[self insertSubview:self.percentageView atIndex:1];

		[self updateBatteryViewWidth:nil];
	}
}

%new
-(BOOL)darkModeEnabled {
	BOOL enabled = FALSE;
    if(NSClassFromString(@"UIUserInterfaceStyleArbiter")){
        if([[NSClassFromString(@"UIUserInterfaceStyleArbiter") sharedInstance] currentStyle] == 2){
            enabled = TRUE;
        } else {
            enabled = FALSE;
        }
    } else {
        if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Noctis12.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.noctis12prefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        } else if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/NoctisXI.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.NoctisXIprefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        }
    }

    return enabled;
}

%end
%end

%group AperioTint
%hook APEPlaceholder
%property (nonatomic, retain) UIView *percentageView;
%property (nonatomic, assign) float batteryPercentageWidth;
%property (nonatomic, assign) float batteryPercentage;

-(void)layoutSubviews {
	%orig;

	[self updateBatteryViewWidth:nil];
}

-(void)didMoveToWindow {
	%orig;
	[self addPercentageBatteryView];
}

%new 
-(void)updateBatteryViewWidth:(NSNotification *)notification {
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		if(!customPercentEnabled){
			self.batteryPercentage = [[UIDevice currentDevice] batteryLevel] * 100;
		} else {
			self.batteryPercentage = customPercent;
		}

		darkModeIsEnabled = [self darkModeEnabled];
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[UIView animateWithDuration:0.2
                 animations:^{
					self.percentageView.frame = CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height);
					if(!disableColoring){
						if(differencColorDarkModeEnabled){
							if(!darkModeIsEnabled){
								if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
									if([lowPowerModeHexCode isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
									}
								} else if([[UIDevice currentDevice] batteryState] == 2){
									if([chargingHexCode isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
									}
								} else if(self.batteryPercentage <= 20){
									if([lowBatteryHexCode isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
									}
								} else {
									if([defaultHexCode isEqualToString:@""]){
										if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
											self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
										} else {
											self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
										}
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
									}
								}
							} else {
								if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
									if([lowPowerModeHexCodeDark isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
									}
								} else if([[UIDevice currentDevice] batteryState] == 2){
									if([chargingHexCodeDark isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
									}
								} else if(self.batteryPercentage <= 20){
									if([lowBatteryHexCodeDark isEqualToString:@""]){
										self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
									}
								} else {
									if([defaultHexCodeDark isEqualToString:@""]){
										if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
											self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
										} else {
											self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
										}
									} else {
										self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
									}
								}
							}
						} else {
							if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
								if([lowPowerModeHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
								}
							} else if([[UIDevice currentDevice] batteryState] == 2){
								if([chargingHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
								}
							} else if(self.batteryPercentage <= 20){
								if([lowBatteryHexCode isEqualToString:@""]){
									self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
								}
							} else {
								if([defaultHexCode isEqualToString:@""]){
									if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
										self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
									}
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
								}
							}
						}
					} else {
						if(differencColorDarkModeEnabled){
							if(!darkModeIsEnabled){
								if([defaultHexCode isEqualToString:@""]){
									if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
										self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
									}
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
								}
							} else {
								if([defaultHexCodeDark isEqualToString:@""]){
									if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
										self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
									} else {
										self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
									}
								} else {
									self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
								}
							}
						} else {
							if([defaultHexCode isEqualToString:@""]){
								if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
									self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
								} else {
									self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
								}
							} else {
								self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
							}
						}
					}
			}];
		});
	});
}

%new
-(void)addPercentageBatteryView {
	otherTweakPrefs();

	if(!self.percentageView){
		[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(updateBatteryViewWidth:)
				name:@"CenamoInfoChanged"
				object:nil];

		self.percentageView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)];
		self.percentageView.alpha = aperioAlphaForBatteryView;

		darkModeIsEnabled = [self darkModeEnabled];

		if(!disableColoring){
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCode isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
						}
					} else {
						if([defaultHexCode isEqualToString:@""]){
							if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
								self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
							}
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
						}
					}
				} else {
					if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
						if([lowPowerModeHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactorDark green:lowPowerModeGreenFactorDark blue:lowPowerModeBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCodeDark];
						}
					} else if([[UIDevice currentDevice] batteryState] == 2){
						if([chargingHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactorDark green:chargingGreenFactorDark blue:chargingBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCodeDark];
						}
					} else if(self.batteryPercentage <= 20){
						if([lowBatteryHexCodeDark isEqualToString:@""]){
							self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactorDark green:lowBatteryGreenFactorDark blue:lowBatteryBlueFactorDark alpha:1.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCodeDark];
						}
					} else {
						if([defaultHexCodeDark isEqualToString:@""]){
							if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
								self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
							} else {
								self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
							}
						} else {
							self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
						}
					}
				}
			} else {
				if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
					if([lowPowerModeHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:lowPowerModeRedFactor green:lowPowerModeGreenFactor blue:lowPowerModeBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowPowerModeHexCode];
					}
				} else if([[UIDevice currentDevice] batteryState] == 2){
					if([chargingHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:chargingRedFactor green:chargingGreenFactor blue:chargingBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:chargingHexCode];
					}
				} else if(self.batteryPercentage <= 20){
					if([lowBatteryHexCode isEqualToString:@""]){
						self.percentageView.backgroundColor = [UIColor colorWithRed:lowBatteryRedFactor green:lowBatteryGreenFactor blue:lowBatteryBlueFactor alpha:1.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:lowBatteryHexCode];
					}
				} else {
					if([defaultHexCode isEqualToString:@""]){
						if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
							self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						}
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
					}
				}
			}
		} else {
			if(differencColorDarkModeEnabled){
				if(!darkModeIsEnabled){
					if([defaultHexCode isEqualToString:@""]){
						if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
							self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
						}
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
					}
				} else {
					if([defaultHexCodeDark isEqualToString:@""]){
						if(defaultRedFactorDark == 1.0 && defaultGreenFactorDark == 1.0 && defaultBlueFactorDark == 1.0){
							self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
						} else {
							self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactorDark green:defaultGreenFactorDark blue:defaultBlueFactorDark alpha:1.0];
						}
					} else {
						self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCodeDark];
					}
				}
			} else {
				if([defaultHexCode isEqualToString:@""]){
					if(defaultRedFactor == 1.0 && defaultGreenFactor == 1.0 && defaultBlueFactor == 1.0){
						self.percentageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
					} else {
						self.percentageView.backgroundColor = [UIColor colorWithRed:defaultRedFactor green:defaultGreenFactor blue:defaultBlueFactor alpha:1.0];
					}
				} else {
					self.percentageView.backgroundColor = [UIColor colorFromHexCode:defaultHexCode];
				}
			}
		}

		[self insertSubview:self.percentageView atIndex:1];
	}
}

%new
-(BOOL)darkModeEnabled {
	BOOL enabled = FALSE;
    if(NSClassFromString(@"UIUserInterfaceStyleArbiter")){
        if([[NSClassFromString(@"UIUserInterfaceStyleArbiter") sharedInstance] currentStyle] == 2){
            enabled = TRUE;
        } else {
            enabled = FALSE;
        }
    } else {
        if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Noctis12.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.noctis12prefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        } else if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/NoctisXI.dylib"]){
            NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.NoctisXIprefs.settings.plist"];
            enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
        }
    }

    return enabled;
}

%end
%end

%group otherStuff

%hook UITraitCollection
- (CGFloat)displayCornerRadius {
	if(XDock){
		return 6;
	} else {
		return %orig;
	}
}
%end

%hook BCBatteryDevice

-(void)setCharging:(BOOL)arg1 {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"CenamoInfoChanged" object:nil userInfo:nil];
    %orig;
}

-(void)setBatterySaverModeActive:(BOOL)arg1 {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"CenamoInfoChanged" object:nil userInfo:nil];
    %orig;
}

-(void)setPercentCharge:(NSInteger)arg1 {

    if(arg1!=0) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CenamoInfoChanged" object:nil userInfo:nil];
    }
    %orig;
}

%end

%end

%ctor {
	preferencesChanged();
	otherTweakPrefs();
	detectFloatingDock();
	aperioDetect();
	oldDockEnabled();
	navaleDetect();

	if(enabled){
		%init(otherStuff);
		if((floatingDockEnabled && kCFCoreFoundationVersionNumber > 1600) || [[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
			if(percentageOrTint == 0){
				%init(SBFloatingDockViewPercentage);
			} else {
				%init(SBFloatingDockViewTint);
			}
		} else if(floatingDockEnabled && kCFCoreFoundationVersionNumber < 1600) {
			
		} else if(!floatingDockEnabled && percentageOrTint == 0){
			%init(SBDockViewPercentage);
		} else {
			%init(SBDockViewTint);
		}

		if(percentageOrTint == 0){
			if(AperioInstalled && aperioEnabled){
					%init(AperioPercentage);
			}
		} else if(percentageOrTint == 1){
			if(AperioInstalled && aperioEnabled){
					%init(AperioTint);
			}
		}
	}
}