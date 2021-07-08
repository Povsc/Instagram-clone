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
@property (nonatomic) BOOL edited;

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
    
    // Caption has not been edited
    self.edited = false;
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.textColor == [UIColor lightGrayColor]) {
        textView.text = nil;
        textView.textColor = [UIColor blackColor];
        self.edited = true;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqual:@""]) {
        textView.text = @"Caption...";
        textView.textColor = [UIColor lightGrayColor];
        self.edited = false;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Resize image
    editedImage = [self resizeImage:editedImage withSize:CGSizeMake(1800, 1800)];
    
    // Set image
    self.imageView.image = editedImage;
    
    // Remove background color
    self.imageView.backgroundColor = nil;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapImage:(id)sender {
    // Set up UIImagePickerController
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    UIAlertController *alert = [self setAlertWithPicker:imagePickerVC];
    [self presentViewController:alert animated:YES completion:^{
        // Do nothing
    }];
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
    if (!self.edited){
        self.captionField.text = @"";
    }
    [Post postUserImage:self.imageView.image
            withCaption: self.captionField.text
         withCompletion:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            
        } else {
            NSLog(@"Posted successfully");
            
            // manually segue to logged in view
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

//Sets up 'AlertController'
- (UIAlertController *)setAlertWithPicker: (UIImagePickerController *)imagePickerVC {
    // Instantiate empty alert
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                               message:nil
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    // create a camera
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
                                                      }];
    // add the camera action to the alertController
    [alert addAction:cameraAction];

    // create an library action
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Photo Library"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
                                                     }];
    // add the library action to the alert controller
    [alert addAction:libraryAction];
    
    return alert;
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
