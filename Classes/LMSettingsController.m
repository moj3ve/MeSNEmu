//
//  LMSettingsController.m
//  MeSNEmu
//
//  Created by Lucas Menge on 1/12/12.
//  Copyright (c) 2012 Lucas Menge. All rights reserved.
//

#import "LMSettingsController.h"

#import "../SNES9X/snes9x.h"

#import "LMMultipleChoicePicker.h"
#import "LMTableViewCellDelegate.h"
#import "LMTableViewNumberCell.h"
#import "LMTableViewSwitchCell.h"

NSString* const kLMSettingsChangedNotification = @"SettingsChanged";

NSString* const kLMSettingsBluetoothController = @"BluetoothController";

NSString* const kLMSettingsSmoothScaling = @"SmoothScaling";
NSString* const kLMSettingsFullScreen = @"FullScreen";
NSString* const kLMSettingsDarkMode = @"DarkMode";

NSString* const kLMSettingsSound = @"Sound";
NSString* const kLMSettingsAutoFrameskip = @"AutoFrameskip";
NSString* const kLMSettingsFrameskipValue = @"FrameskipValue";

NSString* const kLMEmulatorPortName = @"MeSNEmu";

typedef enum _LMSettingsSections
{
    LMSettingsSectionScreen,
    LMSettingsSectionEmulation,
    LMSettingsSectionAbout
} LMSettingsSections;

@interface LMSettingsController(Privates) <LMTableViewCellDelegate, LMMultipleChoicePickerDelegate>
@end

@implementation LMSettingsController(Privates)

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

- (void)LM_toggleDarkMode:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kLMSettingsDarkMode];
}

- (void)LM_toggleSound:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kLMSettingsSound];
}

- (void)LM_toggleAutoFrameskip:(UISwitch*)sender
{
    _changed = YES;
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kLMSettingsAutoFrameskip];
}

- (void)LM_cellValueChanged:(UITableViewCell*)cell
{
    _changed = YES;
    if([[self.tableView indexPathForCell:cell] compare:_frameskipValueIndexPath] == NSOrderedSame)
        [[NSUserDefaults standardUserDefaults] setInteger:((LMTableViewNumberCell*)cell).value forKey:kLMSettingsFrameskipValue];
}

- (LMTableViewNumberCell*)LM_numberCell
{
    static NSString* identifier = @"NumberCell";
    LMTableViewNumberCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
        cell = [[[LMTableViewNumberCell alloc] initWithReuseIdentifier:identifier] autorelease];
    return cell;
}

- (LMTableViewSwitchCell*)LM_switchCell
{
    static NSString* identifier = @"SwitchCell";
    LMTableViewSwitchCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
        cell = [[[LMTableViewSwitchCell alloc] initWithReuseIdentifier:identifier] autorelease];
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

- (void)multipleChoice:(LMMultipleChoicePicker*)picker changedIndex:(int)index
{
    _changed = YES;
    int value = [[picker.optionValues objectAtIndex:index] intValue];
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kLMSettingsBluetoothController];
}

@end

#pragma mark -

@implementation LMSettingsController

@synthesize delegate = _delegate;

- (void)hideSettingsThatRequireReset
{
    _hideSettingsThatRequireReset = YES;
    if(_soundIndexPath != nil)
    {
        [_soundIndexPath release];
        _soundIndexPath = nil;
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
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsSound] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLMSettingsSound];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsAutoFrameskip] == nil)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLMSettingsAutoFrameskip];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kLMSettingsFrameskipValue] == nil)
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kLMSettingsFrameskipValue];
}

@end

#pragma mark -

@implementation LMSettingsController(UITableViewController)

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == LMSettingsSectionScreen)
        return 3;
    else if(section == LMSettingsSectionEmulation)
    {
        if(_soundIndexPath == nil)
            return 2;
        else
            return 3;
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
    if(section == LMSettingsSectionEmulation)
        return NSLocalizedString(@"AUTO_FRAMESKIP_EXPLANATION", nil);
    return nil;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsDarkMode];
    NSInteger section = indexPath.section;
    if(section == LMSettingsSectionScreen)
    {
        if([indexPath compare:_smoothScalingIndexPath] == NSOrderedSame)
        {
            LMTableViewSwitchCell* c = (LMTableViewSwitchCell*)(cell = [self LM_switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsSmoothScaling];
            [c.switchView addTarget:self action:@selector(LM_toggleSmoothScaling:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"SMOOTH_SCALING", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor cyanColor];
            }
        }
        else if([indexPath compare:_fullScreenIndexPath] == NSOrderedSame)
        {
            LMTableViewSwitchCell* c = (LMTableViewSwitchCell*)(cell = [self LM_switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsFullScreen];
            [c.switchView addTarget:self action:@selector(LM_toggleFullScreen:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"Full Screen", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor cyanColor];
            }
        }
        else if([indexPath compare:_darkModeIndexPath] == NSOrderedSame)
        {
            LMTableViewSwitchCell* c = (LMTableViewSwitchCell*)(cell = [self LM_switchCell]);
            
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsDarkMode];
            [c.switchView addTarget:self action:@selector(LM_toggleDarkMode:) forControlEvents:UIControlEventValueChanged];
            c.textLabel.text = NSLocalizedString(@"Dark Mode (Beta)", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor cyanColor];
            }
        }
    }
    else if(section == LMSettingsSectionEmulation)
    {
        if([indexPath compare:_soundIndexPath] == NSOrderedSame)
        {
            LMTableViewSwitchCell* c = (LMTableViewSwitchCell*)(cell = [self LM_switchCell]);
            c.textLabel.text = NSLocalizedString(@"SOUND", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor cyanColor];
            }
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsSound];
            [c.switchView addTarget:self action:@selector(LM_toggleSound:) forControlEvents:UIControlEventValueChanged];
        }
        else if([indexPath compare:_autoFrameskipIndexPath] == NSOrderedSame)
        {
            LMTableViewSwitchCell* c = (LMTableViewSwitchCell*)(cell = [self LM_switchCell]);
            c.textLabel.text = NSLocalizedString(@"Auto Frameskip", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor cyanColor];
            }
            c.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsAutoFrameskip];
            [c.switchView addTarget:self action:@selector(LM_toggleAutoFrameskip:) forControlEvents:UIControlEventValueChanged];
        }
        else if([indexPath compare:_frameskipValueIndexPath] == NSOrderedSame)
        {
            LMTableViewNumberCell* c = (LMTableViewNumberCell*)(cell = [self LM_numberCell]);
            c.textLabel.text = NSLocalizedString(@"Skip Every", nil);
            if (darkMode == YES) {
                c.textLabel.textColor = [UIColor cyanColor];
            }
            c.minimumValue = 0;
            c.maximumValue = 9;
            c.suffix = NSLocalizedString(@"Frames", nil);
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
            cell.textLabel.text = NSLocalizedString(@"VERSION", nil);
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
            cell.textLabel.text = NSLocalizedString(@"Core", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Snes9X %@", [NSString stringWithCString:VERSION encoding:NSUTF8StringEncoding]];
        }
        else if(row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"BY", nil);
            cell.detailTextLabel.text = @"SarahH12099";
        }
    }
    
    return cell;
}

@end

#pragma mark -

@implementation LMSettingsController(UIViewController)

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SETTINGS", nil);
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(LM_done)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    
    _smoothScalingIndexPath = [[NSIndexPath indexPathForRow:0 inSection:LMSettingsSectionScreen] retain];
    _fullScreenIndexPath = [[NSIndexPath indexPathForRow:1 inSection:LMSettingsSectionScreen] retain];
    _darkModeIndexPath = [[NSIndexPath indexPathForRow:2 inSection:LMSettingsSectionScreen] retain];
    
    if(_hideSettingsThatRequireReset == NO)
    {
        _soundIndexPath = [[NSIndexPath indexPathForRow:0 inSection:LMSettingsSectionEmulation] retain];
        _autoFrameskipIndexPath = [[NSIndexPath indexPathForRow:1 inSection:LMSettingsSectionEmulation] retain];
        _frameskipValueIndexPath = [[NSIndexPath indexPathForRow:2 inSection:LMSettingsSectionEmulation] retain];
    }
    else
    {
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

@implementation LMSettingsController(NSObject)

- (id)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if(self)
    {
        [LMSettingsController setDefaultsIfNotDefined];
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
    
    [_soundIndexPath release];
    _soundIndexPath = nil;
    [_autoFrameskipIndexPath release];
    _autoFrameskipIndexPath = nil;
    [_frameskipValueIndexPath release];
    _frameskipValueIndexPath = nil;
    
    [super dealloc];
}

@end
