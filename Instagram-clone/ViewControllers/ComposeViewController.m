//
//  ComposeViewController.m
//  Instagram-clone
//
//  Created by felipeccm on 7/6/21.
//

#import "ComposeViewController.h"
#import "Post.h"

@interface ComposeViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *captionField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.captionField.delegate = self;
    
    // Make caption frame round
    self.captionField.layer.cornerRadius = 10;
    self.captionField.layer.masksToBounds = true;
    
    // Add placeholder text
    self.captionField.text = @"Caption...";
    self.captionField.textColor = [UIColor  lightGrayColor];
    
    //Initiate picker
    [self didTapImage:nil];
    
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.textColor == [UIColor lightGrayColor]) {
        textView.text = nil;
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqual:@""]) {
        textView.text = @"Caption...";
        textView.textColor = [UIColor lightGrayColor];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Resize image
    editedImage = [self resizeImage:editedImage withSize:CGSizeMake(1800, 1800)];
    
    // Set image
    self.imageView.image = editedImage;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapImage:(id)sender {
    // Set up UIImagePickerController
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;


    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (IBAction)onScreenTap:(id)sender {
    [self.view endEditing:TRUE];
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

- (IBAction)didTapShare:(id)sender {
    [Post postUserImage:self.imageView.image
            withCaption: self.captionField.text
         withCompletion:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            
        } else {
            NSLog(@"User registered successfully");
            
            // manually segue to logged in view
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
