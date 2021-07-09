//
//  ProfileCollectionReusableView.h
//  Instagram-clone
//
//  Created by felipeccm on 7/9/21.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ProfileCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet PFImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *username;

@end

NS_ASSUME_NONNULL_END
