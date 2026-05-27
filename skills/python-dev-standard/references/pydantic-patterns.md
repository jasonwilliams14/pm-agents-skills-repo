# Pydantic v2 Patterns

Always use Pydantic v2 for data validation and settings management.

## Basic Model
```python
from pydantic import BaseModel, Field, ConfigDict

class User(BaseModel):
    model_config = ConfigDict(frozen=True, str_strip_whitespace=True)
    
    id: int
    username: str = Field(..., min_length=3, max_length=50)
    email: str = Field(..., pattern=r"^\S+@\S+\.\S+$")
```

## Settings Management
```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class AppConfig(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', env_prefix='APP_')
    
    api_key: str
    debug: bool = False
```

## Validation Patterns
- Use `@field_validator` for custom field validation.
- Use `@model_validator(mode='after')` for cross-field validation.
- Prefer `Annotated` for reusable validation logic.

## Performance
- Use `.model_dump()` and `.model_validate()` instead of the deprecated `.dict()` and `.parse_obj()`.
