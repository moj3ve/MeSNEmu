#import "SettingsController.h"

#import "../Snes9x/snes9x.h"

#import "MultipleChoicePicker.h"
#import "TableViewCellDelegate.h"
#import "TableViewNumberCell.h"
#import "TableViewSwitchCell.h"

NSString* const kLMSettingsChangedNotification = @"SettingsChanged";

NSString* const kLMSettingsBluetoothController = @"BluetoothController";

NSString* const kLMSettingsSmoothScaling = @"SmoothScaling";
NSString* const kLMSettingsFullScreen = @"FullScreen";
NSString* const kLMSettingsDarkMode = @"DarkMode";
NSString* const kLMSettingsRYGBButtons = @"RYGBButtons";

NSString* const kLMSettingsSound = @"Sound";
NSString* const kLMSettingsLRThree = @"LRThree";
NSString* const kLMSettingsAutoFrameskip = @"AutoFrameskip";
NSString* const kLMSettingsFrameskipValue = @"FrameskipValue";

NSString* const kLMEmulatorPortName = @"MeSNEmu";

typedef enum _LMSettingsSections
{
    LMSettingsSectionScreen,
    LMSettingsSectionEmulation,
    LMSettingsSectionAbout
} LMSettingsSections;

@interface SettingsController(Privates) <TableViewCellDelegate, MultipleChoicePickerDelegate>
@end

@implementation SettingsController(Privates)

- (void)LM_done
{
    if(_changed == YES)
        [[NSNotificationCenter defaultCenter] postNotificationName:kLMSettingsChangedNotification object:nil userInfo:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [_delegate settingsDidDismiss:self];
    }];
}

- (void)LM_toggleSmoothScaling:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kLMSettingsSmoothScaling];
}

- (void)LM_toggleFullScreen:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kLMSettingsFullScreen];
}

// Dark Mode Switch Start

- (void)LM_toggleDarkMode:(UISwitch*)sender
{
    NSString *Title = NSLocalizedString(@"NOTICE", nil);
    NSString *Message = NSLocalizedString(@"DARK_MODE_NOTICE", nil);
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:Title
                                 message:Message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIView *firstSubview = alert.view.subviews.firstObject;
    
    UIView *alertContentView = firstSubview.subviews.firstObject;
    for (UIView *subSubView in alertContentView.subviews) {
        BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsDarkMode];
        if (darkMode == YES) {
            subSubView.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.3];
        }
    }
    
    UIAlertAction* noButton = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    if (sender.isOn == 0) {
                                        _changed = YES;
                                        [sender setOn:TRUE animated:YES];
                                    }
                                    else {
                                        _changed = YES;
                                        [sender setOn:FALSE animated:YES];
                                    }
                                }];
    
    UIAlertAction* yesButton = [UIAlertAction
                               actionWithTitle:@"Okay"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   _changed = YES;
                                   [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kLMSettingsDarkMode];
                                   [[NSThread mainThread] exit];
                               }];
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// Dark Mode Switch End

- (void)LM_toggleRYGBButtons:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kLMSettingsRYGBButtons];
}

- (void)LM_toggleSound:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kLMSettingsSound];
}

// L3/R3 Switch Start

- (void)LM_toggleLRThree:(UISwitch*)sender
{
    if (@available(iOS 12.1, *)) {
        _changed = YES;
        [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kLMSettingsLRThree];
    }
    else {
        NSString *Title = NSLocalizedString(@"NOTICE", nil);
        NSString *Message = NSLocalizedString(@"LRTHREE_NOTICE", nil);
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:Title
                                     message:Message
                                     preferredStyle:UIAlertControllerStyleAlert];
    
        UIView *firstSubview = alert.view.subviews.firstObject;
    
        UIView *alertContentView = firstSubview.subviews.firstObject;
        for (UIView *subSubView in alertContentView.subviews) {
            BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsDarkMode];
            if (darkMode == YES) {
                subSubView.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.3];
            }
        }
    
        UIAlertAction* okayButton = [UIAlertAction
                                   actionWithTitle:@"Okay"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       if (sender.isOn == 1) {
                                           _changed = YES;
                                           [sender setOn:FALSE animated:YES];
                                       }
                                       else {
                                           _changed = YES;
                                           [sender setOn:FALSE animated:YES];
                                       }
                                   }];
    
        [alert addAction:okayButton];
    
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// L3/R3 Switch End

- (void)LM_toggleAutoFrameskip:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kLMSettingsAutoFrameskip];
}

- (void)LM_cellValueChanged:(UITableViewCell*)cell
{
    _changed = YES;
    if([[self.tableView indexPathForCell:cell] compare:_frameskipValueIndexPath] == NSOrderedSame)
        [[NSUserDefaults standardUserDefaults] setInteger:((TableViewNumberCell*)cell).value forKey:kLMSettingsFrameskipValue];
}

- (TableViewNumberCell*)LM_numberCell
{
    static NSString* identifier = @"NumberCell";
    TableViewNumberCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
        cell = [[[TableViewNumberCell alloc] initWithReuseIdentifier:identifier] autorelease];
    return cell;
}

- (TableViewSwitchCell*)LM_switchCell
{
    static NSString* identifier = @"SwitchCell";
    TableViewSwitchCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
        cell = [[[TableViewSwitchCell alloc] initWithReuseIdentifier:identifier] autorelease];
    return cell;
}

- (UITableViewCell*)LM_multipleChoiceCell
{
    static NSString* identifier = @"MultipleChoiceCell";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark LMMultipleChoicePickerDelegate

- (void)multipleChoice:(MultipleChoicePicker*)picker changedIndex:(int)index
{
    _changed = YES;
    int value = [[picker.optionValues objectAtIndex:index] intValue];
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kLMSettingsBluetoothController];
}

@end

#pragma mark -

@implementation SettingsController

@synthesize delegate = _delegate;

- (void)hideSettingsThatRequireReset
{
    _hideSettingsThatRequireReset = YES;
    if(_darkModeIndexPath != nil)
    {
        [_darkModeIndexPath release];
        _darkModeIndexPath = nil;
        [self.tableView reloadData];
    }
    if(_rygbButtonsIndexPath != nil)
    {
        [_rygbButtonsIndexPath release];
        _rygbButtonsIndexPath = nil;
        [self.tableView reloadData];
    }
    if(_soundIndexPath != nil)
    {
        [_soundIndexPath release];
        _soundIndexPath = nil;
        [self.tableView reloadData];
    }
    if(_lrThreeIndexPath != nil)
    {
        [_lrThreeIndexPath release];
        _lrThreeIndexPath = nil;
        [self.tableView reloadData];
    }
}

+ (void)setDefaultsIfNotDefined
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsBluetoothController] == nil)
        [[NSUserDefaults standardUserDefaults] setInteger:LMBTControllerType_iCade8Bitty forKey:kLMSettingsBluetoothController];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsSmoothScaling] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLMSettingsSmoothScaling];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsFullScreen] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLMSettingsFullScreen];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsDarkMode] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLMSettingsDarkMode];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsRYGBButtons] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLMSettingsRYGBButtons];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsSound] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLMSettingsSound];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsLRThree] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLMSettingsLRThree];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsAutoFrameskip] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLMSettingsAutoFrameskip];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsFrameskipValue] == nil)
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kLMSettingsFrameskipValue];
}

@end

#pragma mark -

@implementation SettingsController(UITableViewController)

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == LMSettingsSectionScreen)
        if(_darkModeIndexPath == nil && _rygbButtonsIndexPath == nil)
            return 2;
        else
            return 4;
    else if(section == LMSettingsSectionEmulation)
    {
        if(_soundIndexPath == nil && _lrThreeIndexPath == nil)
            return 2;
        else
            return 4;
    }
    else if(section == LMSettingsSectionAbout)
    {
        NSString* bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
        if([bundleName isEqualToString:kLMEmulatorPortName] == YES)
            return 3;
        return 2;
    }
    return 0;
}

- (NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == LMSettingsSectionScreen)
        return NSLocalizedString(@"DARK_MODE_MESSAGE", nil);
    else if(section == LMSettingsSectionEmulation)
        return NSLocalizedString(@"AUTO_FRAMESKIP_MESSAGE", nil);
    return nil;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsDarkMode];
    NSInteger section = indexPath.section;
    if (darkMode == YES) {
        self.view.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.9];
    }
    if(section == LMSettingsSectionScreen)
    {
        if([indexPath compare:_smoothScalingIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self LM_switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsSmoothScaling];
            [c.switchView addTarget:self action:@selector(LM_toggleSmoothScaling:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"SMOOTH_SCALING", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
        }
        else if([indexPath compare:_fullScreenIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self LM_switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsFullScreen];
            [c.switchView addTarget:self action:@selector(LM_toggleFullScreen:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"FULL_SCREEN", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
        }
        else if([indexPath compare:_darkModeIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self LM_switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsDarkMode];
            [c.switchView addTarget:self action:@selector(LM_toggleDarkMode:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"DARK_MODE_TITLE", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
        }
        else if([indexPath compare:_rygbButtonsIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self LM_switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsRYGBButtons];
            [c.switchView addTarget:self action:@selector(LM_toggleRYGBButtons:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"RYGB_BUTTONS", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
        }
    }
    else if(section == LMSettingsSectionEmulation)
    {
        if([indexPath compare:_soundIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self LM_switchCell]);
            c.textLabel.text = NSLocalizedString(@"SOUND", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsSound];
            [c.switchView addTarget:self action:@selector(LM_toggleSound:) forControlEvents:UIControlEventValueChanged];
        }
        else if([indexPath compare:_lrThreeIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self LM_switchCell]);
            c.textLabel.text = NSLocalizedString(@"LRTHREE", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsLRThree];
            [c.switchView addTarget:self action:@selector(LM_toggleLRThree:) forControlEvents:UIControlEventValueChanged];
        }
        else if([indexPath compare:_autoFrameskipIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self LM_switchCell]);
            c.textLabel.text = NSLocalizedString(@"AUTO_FRAMESKIP_TITLE", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsAutoFrameskip];
            [c.switchView addTarget:self action:@selector(LM_toggleAutoFrameskip:) forControlEvents:UIControlEventValueChanged];
        }
        else if([indexPath compare:_frameskipValueIndexPath] == NSOrderedSame)
        {
            TableViewNumberCell* c = (TableViewNumberCell*)(cell = [self LM_numberCell]);
            c.textLabel.text = NSLocalizedString(@"SKIP_EVERY", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
                c.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.9];
            }
            c.minimumValue = 0;
            c.maximumValue = 9;
            c.suffix = NSLocalizedString(@"FRAMES", nil);
            c.allowsDefault = NO;
            c.value = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kLMSettingsFrameskipValue];
            c.delegate = self;
        }
    }
    else if(section == LMSettingsSectionAbout)
    {
        static NSString* identifier = @"AboutCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        int row = (int)indexPath.row;
        if(row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"ABOUT", nil);
            if (darkMode == YES) {
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.9];
            }
            NSString* versionString = [NSString stringWithFormat:@"(%s)", __DATE__];
            NSString* bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
            if([bundleName isEqualToString:kLMEmulatorPortName] == YES)
            {
                versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                         kLMEmulatorPortName,
                                         versionString];
        }
        else if(row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"CORE", nil);
            if (darkMode == YES) {
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.9];
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"CORE_NAME", nil), [NSString stringWithCString:VERSION encoding:NSUTF8StringEncoding]];
        }
        else if(row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"DEVELOPER", nil);
            if (darkMode == YES) {
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.9];
            }
            cell.detailTextLabel.text = NSLocalizedString(@"DEVELOPER_NAME", nil);
        }
    }
    
    return cell;
}

@end

#pragma mark -

@implementation SettingsController(UIViewController)

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SETTINGS", nil);
    BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsDarkMode];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(LM_done)];
    if (darkMode == YES) {
        [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    }
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    
    if(_hideSettingsThatRequireReset == NO)
    {
        _smoothScalingIndexPath = [[NSIndexPath indexPathForRow:0 inSection:LMSettingsSectionScreen] retain];
        _fullScreenIndexPath = [[NSIndexPath indexPathForRow:1 inSection:LMSettingsSectionScreen] retain];
        _darkModeIndexPath = [[NSIndexPath indexPathForRow:2 inSection:LMSettingsSectionScreen] retain];
        _rygbButtonsIndexPath = [[NSIndexPath indexPathForRow:3 inSection:LMSettingsSectionScreen] retain];
        
        _soundIndexPath = [[NSIndexPath indexPathForRow:0 inSection:LMSettingsSectionEmulation] retain];
        _lrThreeIndexPath = [[NSIndexPath indexPathForRow:1 inSection:LMSettingsSectionEmulation] retain];
        _autoFrameskipIndexPath = [[NSIndexPath indexPathForRow:2 inSection:LMSettingsSectionEmulation] retain];
        _frameskipValueIndexPath = [[NSIndexPath indexPathForRow:3 inSection:LMSettingsSectionEmulation] retain];
    }
    else
    {
        _smoothScalingIndexPath = [[NSIndexPath indexPathForRow:0 inSection:LMSettingsSectionScreen] retain];
        _fullScreenIndexPath = [[NSIndexPath indexPathForRow:1 inSection:LMSettingsSectionScreen] retain];
        
        _autoFrameskipIndexPath = [[NSIndexPath indexPathForRow:0 inSection:LMSettingsSectionEmulation] retain];
        _frameskipValueIndexPath = [[NSIndexPath indexPathForRow:1 inSection:LMSettingsSectionEmulation] retain];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    else
        return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end

#pragma mark -

@implementation SettingsController(NSObject)

- (id)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if(self)
    {
        [SettingsController setDefaultsIfNotDefined];
    }
    return self;
}

- (void)dealloc
{
    [_smoothScalingIndexPath release];
    _smoothScalingIndexPath = nil;
    [_fullScreenIndexPath release];
    _fullScreenIndexPath = nil;
    [_darkModeIndexPath release];
    _darkModeIndexPath = nil;
    [_rygbButtonsIndexPath release];
    _rygbButtonsIndexPath = nil;
    
    [_soundIndexPath release];
    _soundIndexPath = nil;
    [_lrThreeIndexPath release];
    _lrThreeIndexPath = nil;
    [_autoFrameskipIndexPath release];
    _autoFrameskipIndexPath = nil;
    [_frameskipValueIndexPath release];
    _frameskipValueIndexPath = nil;
    
    [super dealloc];
}

@end
