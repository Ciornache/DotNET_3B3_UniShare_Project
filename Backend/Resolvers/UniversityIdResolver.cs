using AutoMapper;
using Backend.Data;
using Backend.Features.Users.Dtos;
using Backend.Persistence;

public class UniversityIdResolver : IValueResolver<RegisterUserDto, User, Guid?>
{
    private readonly ApplicationContext _context;

    public UniversityIdResolver(ApplicationContext context) {
        _context = context;
    }

    public Guid? Resolve(RegisterUserDto source, User destination, Guid? destMember, ResolutionContext context)
    {
        var university = _context.Universities
            .FirstOrDefault(u => u.Name == source.UniversityName);

        if (university == null)
        {
            return null; 
        }

        return university.Id;
    }
}