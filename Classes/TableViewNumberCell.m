#import "TableViewNumberCell.h"

@interface TableViewNumberCell(Privates)

- (void)updateLabel;

@end

#pragma mark -

@implementation TableViewNumberCell(Privates)

- (void)updateLabel
{
    if(_allowsDefault == NO)
        _defaultButton.userInteractionEnabled = NO;
    if(_usesDefaultValue == YES)
        [_defaultButton setTitle:NSLocalizedString(@"DEFAULT", nil) forState:UIControlStateNormal];
    else
    {
        [_defaultButton setTitle:[NSString stringWithFormat:@"%i %@", _value, _suffix] forState:UIControlStateNormal];
    }
}

- (void)setup
{
    _delegate = nil;
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end

#pragma mark -

@implementation TableViewNumberCell

- (UIView*)plusMinusAccessoryView
{
    if(_plusMinusAccessoryView == nil)
    {
        UIImage* plusImage = nil;
        UIImage* minusImage = nil;
        UIImage* defaultImage = nil;
        UIImage* plusImageDown = nil;
        UIImage* minusImageDown = nil;
        UIImage* defaultImageDown = nil;
        
        BOOL ios7 = NO;
        if([self respondsToSelector:@selector(tintColor)] == YES)
            ios7 = YES;
        
        if(ios7 == YES)
        {
            plusImage = [UIImage imageNamed:@"ButtonNumberPlus-7.png"];
            plusImage = [plusImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            minusImage = [UIImage imageNamed:@"ButtonNumberMinus-7.png"];
            minusImage = [minusImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            defaultImage = [UIImage imageNamed:@"ButtonNumberDefault-7.png"];
            defaultImage = [defaultImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
            plusImageDown = [UIImage imageNamed:@"ButtonNumberPlusDown-7.png"];
            plusImageDown = [plusImageDown imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            minusImageDown = [UIImage imageNamed:@"ButtonNumberMinusDown-7.png"];
            minusImageDown = [minusImageDown imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            defaultImageDown = [UIImage imageNamed:@"ButtonNumberDefaultDown-7.png"];
            defaultImageDown = [defaultImageDown imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        else
        {
            plusImage = [UIImage imageNamed:@"ButtonNumberPlus.png"];
            minusImage = [UIImage imageNamed:@"ButtonNumberMinus.png"];
            defaultImage = [UIImage imageNamed:@"ButtonNumberDefault.png"];
        }
        
        _plusMinusAccessoryView = [[UIView alloc] initWithFrame:(CGRect){0,0,plusImage.size.width+minusImage.size.width+defaultImage.size.width,defaultImage.size.height}];
        
        if(_minusButton != nil)
        {
            [_minusButton removeFromSuperview];
            [_minusButton release];
        }
        _minusButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [_minusButton setBackgroundImage:minusImage forState:UIControlStateNormal];
        [_minusButton setBackgroundImage:minusImageDown forState:UIControlStateHighlighted];
        _minusButton.bounds = (CGRect){0,0, minusImage.size};
        _minusButton.frame = (CGRect){0,0, minusImage.size};
        [_minusButton addTarget:self action:@selector(minus:) forControlEvents:UIControlEventTouchUpInside];
        [_plusMinusAccessoryView addSubview:_minusButton];
        
        if(_defaultButton != nil)
        {
            [_defaultButton removeFromSuperview];
            [_defaultButton release];
        }
        _defaultButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [_defaultButton setBackgroundImage:defaultImage forState:UIControlStateNormal];
        [_defaultButton setBackgroundImage:defaultImageDown forState:UIControlStateHighlighted];
        _defaultButton.bounds = (CGRect){0,0, defaultImage.size};
        _defaultButton.frame = (CGRect){minusImage.size.width, 0, defaultImage.size};
        [_defaultButton setTitleColor:self.detailTextLabel.textColor forState:UIControlStateNormal];
        if(ios7 == YES)
        {
            [_defaultButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        }
        else
        {
            [_defaultButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_defaultButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.25] forState:UIControlStateHighlighted];
            _defaultButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        }
        _defaultButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _defaultButton.adjustsImageWhenDisabled = NO;
        _defaultButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        [_defaultButton addTarget:self action:@selector(toggleDefault:) forControlEvents:UIControlEventTouchUpInside];
        [_plusMinusAccessoryView addSubview:_defaultButton];
        
        if(_plusButton != nil)
        {
            [_plusButton removeFromSuperview];
            [_plusButton release];
        }
        _plusButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [_plusButton setBackgroundImage:plusImage forState:UIControlStateNormal];
        [_plusButton setBackgroundImage:plusImageDown forState:UIControlStateHighlighted];
        _plusButton.bounds = (CGRect){0,0, plusImage.size};
        _plusButton.frame = (CGRect){minusImage.size.width+defaultImage.size.width,0, plusImage.size};
        [_plusButton addTarget:self action:@selector(plus:) forControlEvents:UIControlEventTouchUpInside];
        [_plusMinusAccessoryView addSubview:_plusButton];
    }
    if(self.accessoryView != _plusMinusAccessoryView)
    {
        self.accessoryView = _plusMinusAccessoryView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return _plusMinusAccessoryView;
}
@synthesize value = _value;
- (void)setValue:(int)i
{
    if(i != _value && i <= _maximumValue && i >= _minimumValue)
    {
        _value = i;
        [self updateLabel];
    }
}
@synthesize minimumValue = _minimumValue;
@synthesize maximumValue = _maximumValue;
@synthesize suffix = _suffix;
- (void)setSuffix:(NSString*)newSuffix
{
    [_suffix release];
    _suffix = [newSuffix copy];
    [self updateLabel];
}
@synthesize usesDefaultValue = _usesDefaultValue;
- (void)setUsesDefaultValue:(BOOL)newValue
{
    if(_usesDefaultValue != newValue)
    {
        _usesDefaultValue = newValue;
        [self updateLabel];
    }
}
@synthesize allowsDefault = _allowsDefault;
- (void)setAllowsDefault:(BOOL)newValue
{
    if(_allowsDefault != newValue)
    {
        _allowsDefault = newValue;
        if(_allowsDefault == NO)
            self.usesDefaultValue = NO;
        [self updateLabel];
    }
}

@synthesize delegate = _delegate;

- (void)plus:(id)sender
{
    self.usesDefaultValue = NO;
    self.value++;
    [_delegate cellValueChanged:self];
}

- (void)minus:(id)sender
{
    self.usesDefaultValue = NO;
    self.value--;
    [_delegate cellValueChanged:self];
}

- (void)toggleDefault:(id)sender
{
    if(_allowsDefault == YES)
    {
        if(_usesDefaultValue == YES)
            self.usesDefaultValue = NO;
        else
            self.usesDefaultValue = YES;
        [_delegate cellValueChanged:self];
    }
}

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
    self = [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    return self;
}

@end

#pragma mark -

@implementation TableViewNumberCell(UITableViewCell)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self plusMinusAccessoryView];
        
        _usesDefaultValue = NO;
        _allowsDefault = YES;
        self.suffix = @"px";
        self.minimumValue = 0;
        self.maximumValue = 100;
        self.value = 1;
        
        [self setup];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self setup];
}

@end

#pragma mark -

@implementation TableViewNumberCell(NSObject)

- (void)dealloc
{
    [_plusMinusAccessoryView release];
    _plusMinusAccessoryView = nil;
    [_plusButton release];
    _plusButton = nil;
    [_minusButton release];
    _minusButton = nil;
    [_defaultButton release];
    _defaultButton = nil;
    
    [super dealloc];
}

@end
