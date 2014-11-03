namespace :news_feed_items do
  task :seed_comments => :environment do
    NewsFeedItem.where('target_id is not null').each do |item|
      if comments = item.target.try(:comments)
        item.news_feed_item_comments.delete_all
        comments.each do |comment|
          item.news_feed_item_comments.create(
            news_feed_item: item,
            body: comment.body,
            user_id: comment.user.id
          )
        end
      end
    end
  end

  task :process_work => :environment do
    GITHUB = User.find_by(username: 'GitHub')

    Work.where('created_at >= ?', 7.days.ago).
    where.not(product: Product.find_by(slug: 'meta')).
    group_by(&:product).each do |product, work|
      if work.count > 5
        users = work.map do |w|
          w.user.try(:username)
        end.reduce({}) do |memo, username|
          if memo[username]
            memo[username] = memo[username] + 1
          else
            memo[username] = 1
          end

          memo
        end

        message = "<ul>"

        users.map do |username, commits|
          if commits == 1
            message = message + "<li>@#{username}: #{commits} commit</li>"
          else
            message = message + "<li>@#{username}: #{commits} commits</li>"
          end
        end

        message = message + "</ul>"

        product.news_feed_items.create(
          source: GITHUB,
          target: NewsFeedItemPost.create(title: "#{work.count} commits pushed this week", description: message)
        )
      end
    end
  end
end
