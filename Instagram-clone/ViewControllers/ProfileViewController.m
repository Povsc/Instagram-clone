//
//  ProfileViewController.m
//  Instagram-clone
//
//  Created by felipeccm on 7/9/21.
//

#import "ProfileViewController.h"
@import Parse;
#import "Post.h"
#import "ProfileCollectionViewCell.h"
#import "ProfileCollectionReusableView.h"
#import "DetailsViewController.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *arrayOfPosts;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery whereKey:@"author" equalTo:PFUser.currentUser];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            
            // Use the new data to update the data source
            self.arrayOfPosts = [posts mutableCopy];
            
            // Reload the tableView now that there is new data
            [self.collectionView reloadData];
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        
        [self.collectionView reloadData];
    }];
    
    // Fix layout for collection view
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 2;
    CGFloat itemsPerLine = 3;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (itemsPerLine -1)) / itemsPerLine;
    CGFloat itemHeight = 1.5 * itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ProfileCollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    Post *post = self.arrayOfPosts[indexPath.item];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.post = post;
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ProfileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCollectionViewCell"
                                                                            forIndexPath:indexPath];
    Post *post = self.arrayOfPosts[indexPath.item];
    cell.post = post;
    cell.postImageView.file = post.image;
    [cell.postImageView loadInBackground];
    return cell;
}
     
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfPosts.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    ProfileCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ProfileCollectionReusableView" forIndexPath:indexPath];
    header.profilePicture.file = [PFUser.currentUser objectForKey:@"profilePicture"];
    [header.profilePicture loadInBackground];
    header.username.text = PFUser.currentUser.username;
    
    return header;
}
- (IBAction)didTapSetPicture:(id)sender {
    // Set up UIImagePickerController
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Resize image
    editedImage = [self resizeImage:editedImage withSize:CGSizeMake(1800, 1800)];
    
    // Save image in the cloud
    PFUser.currentUser[@"profilePicture"] = [Post getPFFileFromImage:editedImage];
    [PFUser.currentUser saveInBackground];
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Reload data
    [PFUser.currentUser fetchInBackgroundWithBlock:^( PFObject * _Nullable object, NSError * _Nullable error) {
        if (error){
            NSLog(@"Error: %@", error.localizedDescription);
        }
        else{
            [self.collectionView reloadData];
        }
    }];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
