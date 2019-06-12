#import "SettingsController.h"

#import "../Snes9x/snes9x.h"

#import "MultipleChoicePicker.h"
#import "TableViewCellDelegate.h"
#import "TableViewNumberCell.h"
#import "TableViewSwitchCell.h"

NSString* const kSettingsChangedNotification = @"SettingsChanged";

// UI Settings
NSString* const kSettingsFullScreen = @"FullScreen";
NSString* const kSettingsDarkMode = @"DarkMode";
NSString* const kSettingsRYGBButtons = @"RYGBButtons";

// Emulator Settings
NSString* const kSettingsSmoothScaling = @"SmoothScaling";
NSString* const kSettingsShowFPS = @"ShowFPS";

// Core Settings
NSString* const kSettingsSound = @"Sound";
NSString* const kSettingsAutoFrameskip = @"AutoFrameskip";
NSString* const kSettingsFrameskipValue = @"FrameskipValue";

// Controller Settings
NSString* const kSettingsBluetoothController = @"BluetoothController";
NSString* const kSettingsLRThree = @"LRThree";

NSString* const kEmulatorPortName = @"MeSNEmu";

typedef enum _SettingsSections
{
    SettingsSectionUI,
    SettingsSectionEmulator,
    SettingsSectionCore,
    SettingsSectionController,
    SettingsSectionAbout
} SettingsSections;

@interface SettingsController(Privates) <TableViewCellDelegate, MultipleChoicePickerDelegate>
@end

@implementation SettingsController(Privates)

- (void)done
{
    if(_changed == YES)
        [[NSNotificationCenter defaultCenter] postNotificationName:kSettingsChangedNotification object:nil userInfo:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [_delegate settingsDidDismiss:self];
    }];
}

// UI Settings Start

- (void)toggleFullScreen:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsFullScreen];
}

- (void)toggleDarkMode:(UISwitch*)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"NOTICE", nil)
                                 message:NSLocalizedString(@"DARK_MODE_NOTICE", nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIView *firstSubview = alert.view.subviews.firstObject;
    
    UIView *alertContentView = firstSubview.subviews.firstObject;
    for (UIView *subSubView in alertContentView.subviews) {
        BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
        if (darkMode == YES) {
            subSubView.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.3];
        }
    }
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"CANCEL", nil)
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
                                actionWithTitle:NSLocalizedString(@"OKAY", nil)
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    _changed = YES;
                                    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsDarkMode];
                                    [[NSThread mainThread] exit];
                                }];
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)toggleRYGBButtons:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsRYGBButtons];
}

// UI Settings End

// Emulator Settings Start

- (void)toggleSmoothScaling:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsSmoothScaling];
}

- (void)toggleShowFPS:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsShowFPS];
}

// Emulator Settings End

// Core Settings Start

- (void)toggleSound:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsSound];
}

- (void)toggleAutoFrameskip:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsAutoFrameskip];
}

- (void)cellValueChanged:(UITableViewCell*)cell
{
    _changed = YES;
    if([[self.tableView indexPathForCell:cell] compare:_frameskipValueIndexPath] == NSOrderedSame)
        [[NSUserDefaults standardUserDefaults] setInteger:((TableViewNumberCell*)cell).value forKey:kSettingsFrameskipValue];
}

- (TableViewNumberCell*)numberCell
{
    static NSString* identifier = @"NumberCell";
    TableViewNumberCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
        cell = [[[TableViewNumberCell alloc] initWithReuseIdentifier:identifier] autorelease];
    return cell;
}

- (TableViewSwitchCell*)switchCell
{
    static NSString* identifier = @"SwitchCell";
    TableViewSwitchCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
        cell = [[[TableViewSwitchCell alloc] initWithReuseIdentifier:identifier] autorelease];
    return cell;
}

// Core Settings End

// Controller Settings Start

- (UITableViewCell*)multipleChoiceCell
{
    static NSString* identifier = @"MultipleChoiceCell";
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)toggleLRThree:(UISwitch*)sender
{
    if (@available(iOS 12.1, *)) {
        _changed = YES;
        [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsLRThree];
    }
    else {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"NOTICE", nil)
                                     message:NSLocalizedString(@"LRTHREE_NOTICE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIView *firstSubview = alert.view.subviews.firstObject;
        
        UIView *alertContentView = firstSubview.subviews.firstObject;
        for (UIView *subSubView in alertContentView.subviews) {
            BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
            if (darkMode == YES) {
                subSubView.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.3];
            }
        }
        
        UIAlertAction* okayButton = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"OKAY", nil)
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

// Controller Settings End

#pragma mark MultipleChoicePickerDelegate

- (void)multipleChoice:(MultipleChoicePicker*)picker changedIndex:(int)index
{
    _changed = YES;
    int value = [[picker.optionValues objectAtIndex:index] intValue];
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kSettingsBluetoothController];
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
    // UI Settings
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSettingsFullScreen] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingsFullScreen];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSettingsDarkMode] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingsDarkMode];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSettingsRYGBButtons] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingsRYGBButtons];
    
    // Emulator Settings
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSettingsSmoothScaling] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingsSmoothScaling];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSettingsShowFPS] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingsShowFPS];
    
    // Core Settings
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSettingsSound] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingsSound];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSettingsAutoFrameskip] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingsAutoFrameskip];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSettingsFrameskipValue] == nil)
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kSettingsFrameskipValue];
    
    // Controller Settings
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSettingsBluetoothController] == nil)
        [[NSUserDefaults standardUserDefaults] setInteger:BTControllerType_nControl forKey:kSettingsBluetoothController];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSettingsLRThree] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingsLRThree];
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
    return 5;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == SettingsSectionUI)
    {
        if(_darkModeIndexPath == nil && _rygbButtonsIndexPath == nil)
            return 1;
        else
            return 3;
    }
    else if(section == SettingsSectionEmulator)
    {
        return 2;
    }
    else if(section == SettingsSectionCore)
    {
        if(_soundIndexPath == nil)
            return 2;
        else
            return 3;
    }
    else if(section == SettingsSectionController)
    {
         if(_lrThreeIndexPath == nil)
             return 1;
         else
            return 2;
    }
    else if(section == SettingsSectionAbout)
    {
        return 3;
    }
    return 0;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == SettingsSectionUI)
        return NSLocalizedString(@"UI_SETTINGS", nil);
    else if(section == SettingsSectionEmulator)
        return NSLocalizedString(@"EMULATOR_SETTINGS", nil);
    else if(section == SettingsSectionCore)
        return NSLocalizedString(@"CORE_SETTINGS", nil);
    else if(section == SettingsSectionController)
        return NSLocalizedString(@"CONTROLLER_SETTINGS", nil);
    else if(section == SettingsSectionAbout)
        return NSLocalizedString(@"ABOUT_SETTINGS", nil);
    return nil;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
    NSInteger section = indexPath.section;
    if (darkMode == YES) {
        self.view.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.08 alpha:1.0];
    }
    if(section == SettingsSectionUI)
    {
        if([indexPath compare:_fullScreenIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsFullScreen];
            [c.switchView addTarget:self action:@selector(toggleFullScreen:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"FULL_SCREEN", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
        }
        else if([indexPath compare:_darkModeIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
            [c.switchView addTarget:self action:@selector(toggleDarkMode:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"DARK_MODE_TITLE", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
        }
        else if([indexPath compare:_rygbButtonsIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsRYGBButtons];
            [c.switchView addTarget:self action:@selector(toggleRYGBButtons:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"RYGB_BUTTONS", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
        }
    }
    else if(section == SettingsSectionEmulator)
    {
        if([indexPath compare:_smoothScalingIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSmoothScaling];
            [c.switchView addTarget:self action:@selector(toggleSmoothScaling:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"SMOOTH_SCALING", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
        }
        else if([indexPath compare:_showFPSIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowFPS];
            [c.switchView addTarget:self action:@selector(toggleShowFPS:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"SHOW_FPS", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
        }
    }
    else if(section == SettingsSectionCore)
    {
        if([indexPath compare:_soundIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self switchCell]);
            c.textLabel.text = NSLocalizedString(@"SOUND", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSound];
            [c.switchView addTarget:self action:@selector(toggleSound:) forControlEvents:UIControlEventValueChanged];
        }
        else if([indexPath compare:_autoFrameskipIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self switchCell]);
            c.textLabel.text = NSLocalizedString(@"AUTO_FRAMESKIP_TITLE", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsAutoFrameskip];
            [c.switchView addTarget:self action:@selector(toggleAutoFrameskip:) forControlEvents:UIControlEventValueChanged];
        }
        else if([indexPath compare:_frameskipValueIndexPath] == NSOrderedSame)
        {
            TableViewNumberCell* c = (TableViewNumberCell*)(cell = [self numberCell]);
            c.textLabel.text = NSLocalizedString(@"SKIP_EVERY", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
                c.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.12 alpha:1.0];
            }
            c.minimumValue = 0;
            c.maximumValue = 9;
            c.suffix = NSLocalizedString(@"FRAMES", nil);
            c.allowsDefault = NO;
            c.value = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsFrameskipValue];
            c.delegate = self;
        }
    }
    else if(section == SettingsSectionController)
    {
        if([indexPath compare:_controllerIndexPath] == NSOrderedSame)
        {
            cell = [self multipleChoiceCell];
            cell.textLabel.text = NSLocalizedString(@"CONTROLLER", nil);
            if (darkMode == YES) {
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.12 alpha:1.0];
            }
            NSString* controllerName = nil;
            BTControllerType bluetoothControllerType = [[NSUserDefaults standardUserDefaults] integerForKey:kSettingsBluetoothController];
            
            for(NSArray* controller in [BTControllerView supportedControllers])
            {
                if([[controller objectAtIndex:1] intValue] == bluetoothControllerType)
                {
                    controllerName = [controller objectAtIndex:0];
                    break;
                }
            }
            
            cell.detailTextLabel.text = controllerName;
        }
        else if([indexPath compare:_lrThreeIndexPath] == NSOrderedSame)
        {
            TableViewSwitchCell* c = (TableViewSwitchCell*)(cell = [self switchCell]);
            c.textLabel.text = NSLocalizedString(@"LRTHREE", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor whiteColor];
            }
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsLRThree];
            [c.switchView addTarget:self action:@selector(toggleLRThree:) forControlEvents:UIControlEventValueChanged];
        }
    }
    else if(section == SettingsSectionAbout)
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
            if([bundleName isEqualToString:kEmulatorPortName] == YES)
            {
                versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                         kEmulatorPortName,
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

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = indexPath.section;
    if(section == SettingsSectionController)
    {
        if(indexPath.row == 0)
        {
            MultipleChoicePicker* c = [[MultipleChoicePicker alloc] initWithStyle:UITableViewStyleGrouped];
            c.title = NSLocalizedString(@"CONTROLLER", nil);
            
            // building the option names and values for the controllers
            NSMutableArray* optionNames = [NSMutableArray array];
            NSMutableArray* optionValues = [NSMutableArray array];
            for(NSArray* controller in [BTControllerView supportedControllers])
            {
                [optionNames addObject:[controller firstObject]];
                [optionValues addObject:[controller objectAtIndex:1]];
            }
            c.optionNames = optionNames;
            c.optionValues = optionValues;
            
            BTControllerType controllerType = [[NSUserDefaults standardUserDefaults] integerForKey:kSettingsBluetoothController];
            for(int i=0; i<[c.optionValues count]; i++)
            {
                if([[c.optionValues objectAtIndex:i] intValue] == controllerType)
                {
                    c.pickedIndex = i;
                    break;
                }
            }
            c.delegate = self;
            [self.navigationController pushViewController:c animated:YES];
            [c release];
        }
    }
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
    BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
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
        _fullScreenIndexPath = [[NSIndexPath indexPathForRow:0 inSection:SettingsSectionUI] retain];
        _darkModeIndexPath = [[NSIndexPath indexPathForRow:1 inSection:SettingsSectionUI] retain];
        _rygbButtonsIndexPath = [[NSIndexPath indexPathForRow:2 inSection:SettingsSectionUI] retain];
        
        _smoothScalingIndexPath = [[NSIndexPath indexPathForRow:0 inSection:SettingsSectionEmulator] retain];
        _showFPSIndexPath = [[NSIndexPath indexPathForRow:1 inSection:SettingsSectionEmulator] retain];
        
        _soundIndexPath = [[NSIndexPath indexPathForRow:0 inSection:SettingsSectionCore] retain];
        _autoFrameskipIndexPath = [[NSIndexPath indexPathForRow:1 inSection:SettingsSectionCore] retain];
        _frameskipValueIndexPath = [[NSIndexPath indexPathForRow:2 inSection:SettingsSectionCore] retain];
        
        _controllerIndexPath = [[NSIndexPath indexPathForRow:0 inSection:SettingsSectionController] retain];
        _lrThreeIndexPath = [[NSIndexPath indexPathForRow:1 inSection:SettingsSectionController] retain];
    }
    else
    {
        _fullScreenIndexPath = [[NSIndexPath indexPathForRow:0 inSection:SettingsSectionUI] retain];
        
        _smoothScalingIndexPath = [[NSIndexPath indexPathForRow:0 inSection:SettingsSectionEmulator] retain];
        _showFPSIndexPath = [[NSIndexPath indexPathForRow:1 inSection:SettingsSectionEmulator] retain];
        
        _autoFrameskipIndexPath = [[NSIndexPath indexPathForRow:0 inSection:SettingsSectionCore] retain];
        _frameskipValueIndexPath = [[NSIndexPath indexPathForRow:1 inSection:SettingsSectionCore] retain];
        
        _controllerIndexPath = [[NSIndexPath indexPathForRow:0 inSection:SettingsSectionController] retain];
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
    [_fullScreenIndexPath release];
    _fullScreenIndexPath = nil;
    [_darkModeIndexPath release];
    _darkModeIndexPath = nil;
    [_rygbButtonsIndexPath release];
    _rygbButtonsIndexPath = nil;
    
    [_smoothScalingIndexPath release];
    _smoothScalingIndexPath = nil;
    
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
