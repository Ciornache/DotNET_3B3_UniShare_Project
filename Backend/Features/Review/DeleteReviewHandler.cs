using Backend.Persistence;
using MediatR;

namespace Backend.Features.Review;

public class DeleteReviewHandler(ApplicationContext dbContext, ILogger<DeleteReviewHandler> logger) : IRequestHandler<DeleteReviewRequest, IResult>
{
    public Task<IResult> Handle(DeleteReviewRequest request, CancellationToken cancellationToken)
    {
        
        var review = dbContext.Reviews.Find(request.id);
        
        if (review == null)
        {
            logger.LogWarning("Review with ID {ReviewId} not found.", request.id);
            return Task.FromResult(Results.NotFound($"Review with ID {request.id} not found.") as IResult);
        }

        dbContext.Reviews.Remove(review);
        dbContext.SaveChanges();
        
        logger.LogInformation("Deleted review with ID {ReviewId} from the database.", request.id);
        return Task.FromResult(Results.Ok($"Review with ID {request.id} deleted successfully.") as IResult);
        
    }
}

