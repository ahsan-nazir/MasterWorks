#import <UIKit/UIKit.h>


@interface NewsItemCell_home : UITableViewCell



@property (strong, nonatomic) IBOutlet UILabel *lblTitleNews;

@property (strong, nonatomic) IBOutlet UILabel *lblDescriptionNews;


@property (weak, nonatomic) IBOutlet UIImageView *bgcolorImage;


@property (strong, nonatomic) IBOutlet UIImageView *imgVideo;


@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *numberOfLikes;
@property (weak, nonatomic) IBOutlet UIButton *GetCouponBTn;
@property (weak, nonatomic) IBOutlet UIButton *orderBtn;

@end
