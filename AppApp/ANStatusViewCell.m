/*
 Copyright (c) 2012 T. Chroma, M. Herzog, N. Pannuto, J.Pittman, R. Rottmann, B. Sneed, V. Speelman
 The AppApp source code is distributed under the The MIT License (MIT) license.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.
 
 Any end-user product or application build based on this code, must include the following acknowledgment:
 
 "This product includes software developed by the original AppApp team and its contributors", in the software
 itself, including a link to www.app-app.net.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
*/

#import <QuartzCore/QuartzCore.h>
#import "ANStatusViewCell.h"
#import "NSDictionary+SDExtensions.h"
#import "NSDate+SDExtensions.h"
#import "NSDate+ANExtensions.h"

CGFloat const ANStatusViewCellTopMargin = 10.0;
CGFloat const ANStatusViewCellBottomMargin = 15.0;
CGFloat const ANStatusViewCellLeftMargin = 10.0;
CGFloat const ANStatusViewCellUsernameTextHeight = 15.0;
CGFloat const ANStatusViewCellAvatarHeight = 50.0;
CGFloat const ANStatusViewCellAvatarWidth = 50.0;

@interface ANStatusViewCell()
{
    UIButton *showUserButton;
    ANImageView *avatarView;
    UILabel *usernameTextLabel;
    UILabel *created_atTextLabel;
    UIView *postView;
}

- (void)registerObservers;
- (void)unregisterObservers;

@end

@implementation ANStatusViewCell
@synthesize postData, showUserButton, avatarView, statusTextLabel, postView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.clipsToBounds = YES;
                
        UIColor* borderColor = [UIColor colorWithRed:157.0/255.0 green:167.0/255.0 blue:178.0/255.0 alpha:1.0];
        UIColor* textColor = [UIColor colorWithRed:30.0/255.0 green:88.0/255.0 blue:119.0/255.0 alpha:1.0];
        UIColor *highlightedTextColor = textColor;
        // future avatar
        avatarView = [[ANImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        avatarView.backgroundColor = [UIColor clearColor];
        avatarView.layer.borderWidth = 1.0;
        avatarView.layer.borderColor = [borderColor CGColor];
        [self.contentView addSubview: avatarView];

        showUserButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        showUserButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: showUserButton];
        
        UIColor *postColor = [UIColor colorWithRed:243.0/255.0 green:247.0/255.0 blue:251.0/255.0 alpha:1.0];
        postView = [[UIView alloc] initWithFrame:CGRectMake(70,0,250,100)];
        postView.alpha = 1.0;
        postView.clipsToBounds = YES;
        self.postView.backgroundColor = postColor;
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(70,0,250,100)];
        self.selectedBackgroundView.backgroundColor = postColor;
        
        _leftBorder = [[CALayer alloc] init];
        _leftBorder.frame = CGRectMake(0,0,1,self.bounds.size.height);
        _leftBorder.backgroundColor = [borderColor CGColor];
        [self.postView.layer addSublayer:_leftBorder];
        
        _bottomBorder = [[CALayer alloc] init];
        _bottomBorder.frame = CGRectMake(0,0,self.bounds.size.width,1);
        _bottomBorder.backgroundColor = [borderColor CGColor];
        [self.postView.layer addSublayer:_bottomBorder];
        
        _topBorder = [[CALayer alloc] init];
        _topBorder.frame = CGRectMake(1,0,self.bounds.size.width-1,1);
        _topBorder.backgroundColor = [[UIColor whiteColor] CGColor];
        [self.postView.layer addSublayer:_topBorder];
        
        _avatarConnector = [[CALayer alloc] init];
        _avatarConnector.frame = CGRectMake(60,0,10,1);
        _avatarConnector.backgroundColor = [borderColor CGColor];
        [self.contentView.layer addSublayer:_avatarConnector];
        
        [self.contentView addSubview: postView];
        
        // username
        usernameTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 15)];
        usernameTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
        usernameTextLabel.backgroundColor = postColor;
        usernameTextLabel.textColor = textColor;
        usernameTextLabel.highlightedTextColor = highlightedTextColor;
        [self.postView addSubview: usernameTextLabel];
        
        //created_atTextLabel
        created_atTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 10, 55, 15)];
        created_atTextLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
        created_atTextLabel.backgroundColor = postColor;
        created_atTextLabel.highlightedTextColor = highlightedTextColor;
        created_atTextLabel.textColor = [UIColor grayColor];
        created_atTextLabel.textAlignment = UITextAlignmentRight;
        [self.postView addSubview: created_atTextLabel];
        
        // status label
        statusTextLabel = [[ANPostLabel alloc] initWithFrame:CGRectMake(80, 27, 230, 100)];
        statusTextLabel.backgroundColor = postColor;
        statusTextLabel.clipsToBounds = YES;
       
        [self addSubview: statusTextLabel];
        
        // register observers
        [self registerObservers];
    }
    return self;
}

-(void) dealloc
{
    [self unregisterObservers];
}

- (void)registerObservers
{
    [self addObserver:self forKeyPath:@"postData" options:0 context:0];
    [self addObserver:self forKeyPath:@"username" options:0 context:0];
    [self addObserver:self forKeyPath:@"created_at" options:0 context:0];

}

- (void)unregisterObservers
{
    [self removeObserver:self forKeyPath:@"postData"];
    [self removeObserver:self forKeyPath:@"username"];
    [self removeObserver:self forKeyPath:@"created_at"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"postData"])
    {
        statusTextLabel.postText = [self.postData stringForKey:@"text"];
        
        // handle frame resize
        /*CGSize maxStatusLabelSize = CGSizeMake(240,120);
        CGSize statusLabelSize = [[self.postData objectForKey:@"text"] sizeWithFont: statusTextLabel.font
                                              constrainedToSize:maxStatusLabelSize
                                              lineBreakMode: statusTextLabel.lineBreakMode];
    
        CGRect statusLabelNewFrame = statusTextLabel.frame;
        statusLabelNewFrame.size.height = statusLabelSize.height;
        statusTextLabel.frame = statusLabelNewFrame;*/
        
        CGSize size = [statusTextLabel sizeThatFits:CGSizeMake(230, 10000)];//[statusTextLabel suggestedFrameSizeToFitEntireStringConstraintedToWidth:230];
        CGRect statusLabelNewFrame = statusTextLabel.frame;
        statusLabelNewFrame.size = size;
        statusTextLabel.frame = statusLabelNewFrame;
        
        NSString *username = [self.postData stringForKeyPath:@"user.username"];
        usernameTextLabel.text = username;
        
        NSDate *createdAt = [NSDate dateFromISO8601String:[self.postData stringForKey:@"created_at"]];
        created_atTextLabel.text = [createdAt stringInterval];
        
        NSString *avatarURL = [self.postData stringForKeyPath:@"user.avatar_image.url"];
        avatarView.imageURL = avatarURL;
    }
}

- (void)prepareForReuse
{
    avatarView.image = [UIImage imageNamed:@"avatarPlaceholder.png"];
    avatarView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)selected
{
    if(selected) {
        [self.postView.superview bringSubviewToFront:self.postView];
        self.postView.backgroundColor = [UIColor whiteColor];
    } else {
        self.postView.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:247.0/255.0 blue:251.0/255.0 alpha:1.0];
    }
}

-(void)layoutSubviews {
    // size the post views according to the height of the cell
    self.postView.frame = CGRectMake(self.postView.frame.origin.x,self.postView.frame.origin.y,
                                     self.postView.frame.size.width,self.frame.size.height);
    _leftBorder.frame = CGRectMake(_leftBorder.frame.origin.x,_leftBorder.frame.origin.y,
                                     _leftBorder.frame.size.width,self.frame.size.height);
    _bottomBorder.frame = CGRectMake(_bottomBorder.frame.origin.x,self.frame.size.height-1.0,
                                   _bottomBorder.frame.size.width,_bottomBorder.frame.size.height);
    
    _avatarConnector.frame = CGRectMake(_avatarConnector.frame.origin.x,round(10.0+avatarView.frame.size.height/2.0),
                                     _avatarConnector.frame.size.width,_avatarConnector.frame.size.height);
    
     self.selectedBackgroundView.frame = CGRectMake(self.selectedBackgroundView.frame.origin.x,
                                                    self.selectedBackgroundView.frame.origin.y,
                                                    self.selectedBackgroundView.frame.size.width,
                                                    self.frame.size.height);
}

@end
