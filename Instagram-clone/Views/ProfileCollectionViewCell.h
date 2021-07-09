//
//  ProfileCollectionViewCell.h
//  Instagram-clone
//
//  Created by felipeccm on 7/9/21.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;


NS_ASSUME_NONNULL_BEGIN

@interface ProfileCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *postImageView;
@property (strong, nonatomic) Post *post;

@end

NS_ASSUME_NONNULL_END
