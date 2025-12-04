using MediatR;

namespace Backend.Features.Review;

public record DeleteReviewRequest(Guid id) : IRequest<IResult>;