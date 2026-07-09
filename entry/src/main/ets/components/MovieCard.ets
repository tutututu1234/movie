import { MovieType } from '../model/MovieModel';

/**
 * 影视卡片组件
 */
@Component
export struct MovieCard {
  @Prop movieTitle: string = '';
  @Prop posterPath: string = '';
  @Prop voteAverage: number = 0;
  @Prop releaseDate: string = '';
  @Prop mediaType: string = 'movie';
  onCardClick: () => void = () => {};

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.posterPath)
          .alt('海报')
          .width('100%')
          .aspectRatio(3 / 4)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)

        Text(this.mediaType === MovieType.TV ? '剧集' : '电影')
          .fontSize(10)
          .fontColor('#FFFFFF')
          .backgroundColor(this.mediaType === MovieType.TV ? '#FF6B35' : '#4A90D9')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
          .margin(6)
      }
      .width('100%')

      Text(this.movieTitle)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: 6 })

      Row() {
        Row() {
          Text('★').fontSize(12).fontColor('#FFB800')

          Text(String(Number(this.voteAverage).toFixed(1)))
            .fontSize(12)
            .fontColor('#FFB800')
            .margin({ left: 2 })
        }

        Text(this.releaseDate.substring(0, 4))
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 4 })
    }
    .width('100%')
    .onClick(() => {
      this.onCardClick();
    })
  }
}
