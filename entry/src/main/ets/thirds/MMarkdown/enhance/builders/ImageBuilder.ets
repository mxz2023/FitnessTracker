import { ImageImpl } from '../impl/ImageImpl';
import { ImageNode } from '../model/TreeNode';

@Builder
export function ImageBuilder(markdownUnion: string, item: ImageNode) {
  ImageSpan(ImageImpl.handleImageSrc(markdownUnion, item.url))
    .width(ImageImpl.handleImageWidth(markdownUnion))
    .height(ImageImpl.handleImageHeight(markdownUnion))
    .constraintSize({
      maxWidth: ImageImpl.handleImageMaxWidth(markdownUnion),
      maxHeight: ImageImpl.handleImageMaxHeight(markdownUnion)
    })
    .backgroundColor("#EEE")
    .objectFit(ImageFit.Cover)
    .borderRadius(14)
    .margin({ top: 4, bottom: 4 })
    .onClick(() => {
      ImageImpl.handleClick(markdownUnion, item.url)
    })
}