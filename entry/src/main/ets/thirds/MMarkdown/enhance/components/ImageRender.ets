import { ImageImpl } from '../impl/ImageImpl'
import { ImageNode } from '../model/TreeNode'

/**
 * @deprecated
 */
@Component
export struct ImageRender {
  @Consume markdownUnion: string
  @State image: ImageNode | undefined = undefined

  build() {
    Image(ImageImpl.handleImageSrc(this.markdownUnion, this.image?.url))
      .width(ImageImpl.handleImageWidth(this.markdownUnion))
      .height(ImageImpl.handleImageHeight(this.markdownUnion))
      .constraintSize({
        maxWidth: ImageImpl.handleImageMaxWidth(this.markdownUnion),
        maxHeight: ImageImpl.handleImageMaxHeight(this.markdownUnion)
      })
      .borderRadius(14)
      .backgroundColor("#EEE")
  }
}